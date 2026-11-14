let

    // -------------------------------------------------------
    // PRODUCT LIST + OPTIONAL HISTORICAL RECORDS
    // -------------------------------------------------------

    ProductMap =
        #table(
            type table
            [
                CFTCCode = text,
                Product = text,
                Category = text,
                Sort = Int64.Type,
                BaseRecordLong = nullable number,
                BaseRecordShort = nullable number
            ],
            {
                {"002602","Corn","GRAINS",1,null,null},
                {"001602","Wheat","GRAINS",2,null,null},
                {"005602","Soybeans","GRAINS",3,null,null},
                {"001612","KC Wheat","GRAINS",4,null,null},
                {"001626","MN Wheat","GRAINS",5,null,null},
                {"007601","Soybean Oil","GRAINS",6,null,null},
                {"026603","Soybean Meal","GRAINS",7,null,null},
                {"135731","Canola","GRAINS",8,null,null},
                {"039601","Rough Rice","GRAINS",9,null,null},

                {"057642","Live Cattle","LIVESTOCK",10,null,null},
                {"061641","Feeder Cattle","LIVESTOCK",11,null,null},
                {"054642","Lean Hogs","LIVESTOCK",12,null,null},

                {"111659","RBOB","ENERGIES",13,null,null},
                {"067651","Crude Oil","ENERGIES",14,null,null},
                {"022651","Heating Oil","ENERGIES",15,null,null},
                {"023651","Natural Gas","ENERGIES",16,null,null},
                {"025651","Chicago Ethanol","ENERGIES",17,null,null},

                {"085692","Copper","METALS",18,null,null},
                {"088691","Gold","METALS",19,null,null},
                {"084691","Silver","METALS",20,null,null},
                {"076651","Platinum","METALS",21,null,null},
                {"075651","Palladium","METALS",22,null,null},

                {"083731","Coffee","SOFTS",23,null,null},
                {"080732","Sugar","SOFTS",24,null,null},
                {"073732","Cocoa","SOFTS",25,null,null},
                {"033661","Cotton","SOFTS",26,null,null},
                {"040701","OJ","SOFTS",27,null,null},
                {"058644","Lumber","SOFTS",28,null,null}
            }
        ),


    // -------------------------------------------------------
    // NUMBER CONVERTER
    // -------------------------------------------------------

    N =
        (x as any) as nullable number =>
            try Number.FromText(Text.Trim(Text.From(x)), "en-US")
            otherwise null,


    // -------------------------------------------------------
    // OFFICIAL CFTC CURRENT COMBINED FILE
    // NO API
    // NO TOKEN
    // NO $WHERE
    // NO $SELECT
    // -------------------------------------------------------

    Source =
        Csv.Document(
            Web.Contents(
                "https://www.cftc.gov/dea/newcot/c_disagg.txt"
            ),
            [
                Delimiter = ",",
                Columns = 191,
                Encoding = 1252,
                QuoteStyle = QuoteStyle.Csv
            ]
        ),


    // -------------------------------------------------------
    // CLEAN CFTC CONTRACT CODE
    // -------------------------------------------------------

    CleanCode =
        Table.TransformColumns(
            Source,
            {
                {
                    "Column4",
                    each Text.PadStart(
                        Text.Trim(Text.From(_)),
                        6,
                        "0"
                    ),
                    type text
                }
            }
        ),


    // -------------------------------------------------------
    // KEEP ONLY OUR PRODUCTS
    // -------------------------------------------------------

    FilterProducts =
        Table.SelectRows(
            CleanCode,
            each
                List.Contains(
                    ProductMap[CFTCCode],
                    [Column4]
                )
        ),


    // -------------------------------------------------------
    // ADD PRODUCT / CATEGORY NAMES
    // -------------------------------------------------------

    JoinProducts =
        Table.NestedJoin(
            FilterProducts,
            {"Column4"},
            ProductMap,
            {"CFTCCode"},
            "ProductInfo",
            JoinKind.Inner
        ),

    ExpandProducts =
        Table.ExpandTableColumn(
            JoinProducts,
            "ProductInfo",
            {
                "Product",
                "Category",
                "Sort",
                "BaseRecordLong",
                "BaseRecordShort"
            },
            {
                "Product",
                "Category",
                "Sort",
                "BaseRecordLong",
                "BaseRecordShort"
            }
        ),


    // -------------------------------------------------------
    // REPORT DATES
    // -------------------------------------------------------

    AddReportDate =
        Table.AddColumn(
            ExpandProducts,
            "Report Date",
            each
                Date.FromText(
                    Text.Trim(
                        Text.From([Column3])
                    )
                ),
            type date
        ),

    AddPreviousDate =
        Table.AddColumn(
            AddReportDate,
            "Previous Report Date",
            each Date.AddDays([Report Date], -7),
            type date
        ),


    // -------------------------------------------------------
    // PRODUCER / MERCHANT
    //
    // Column9  = Long
    // Column10 = Short
    // Column57 = Weekly Long Change
    // Column58 = Weekly Short Change
    // -------------------------------------------------------

    AddProducerNet =
        Table.AddColumn(
            AddPreviousDate,
            "Producer Net",
            each N([Column9]) - N([Column10]),
            Int64.Type
        ),

    AddProducerWeekly =
        Table.AddColumn(
            AddProducerNet,
            "Producer Weekly",
            each N([Column57]) - N([Column58]),
            Int64.Type
        ),


    // -------------------------------------------------------
    // SWAP DEALERS
    // -------------------------------------------------------

    AddSwapNet =
        Table.AddColumn(
            AddProducerWeekly,
            "Swap Net",
            each N([Column11]) - N([Column12]),
            Int64.Type
        ),

    AddSwapWeekly =
        Table.AddColumn(
            AddSwapNet,
            "Swap Weekly",
            each N([Column59]) - N([Column60]),
            Int64.Type
        ),


    // -------------------------------------------------------
    // MANAGED MONEY
    // -------------------------------------------------------

    AddMMNet =
        Table.AddColumn(
            AddSwapWeekly,
            "Managed Money Net",
            each N([Column14]) - N([Column15]),
            Int64.Type
        ),

    AddMMWeekly =
        Table.AddColumn(
            AddMMNet,
            "MM Weekly",
            each N([Column62]) - N([Column63]),
            Int64.Type
        ),


    // -------------------------------------------------------
    // RECORD LONG
    // -------------------------------------------------------

    AddRecordLong =
        Table.AddColumn(
            AddMMWeekly,
            "Record Long",
            each
                if [BaseRecordLong] = null or [Managed Money Net] = null then null
                else if [Managed Money Net] > [BaseRecordLong]
                then [Managed Money Net]
                else [BaseRecordLong],
            Int64.Type
        ),


    // -------------------------------------------------------
    // RECORD SHORT
    // -------------------------------------------------------

    AddRecordShort =
        Table.AddColumn(
            AddRecordLong,
            "Record Short",
            each
                if [BaseRecordShort] = null or [Managed Money Net] = null then null
                else if [Managed Money Net] < [BaseRecordShort]
                then [Managed Money Net]
                else [BaseRecordShort],
            Int64.Type
        ),


    // -------------------------------------------------------
    // OTHER REPORTABLES
    // -------------------------------------------------------

    AddOtherNet =
        Table.AddColumn(
            AddRecordShort,
            "Other Net",
            each N([Column17]) - N([Column18]),
            Int64.Type
        ),

    AddOtherWeekly =
        Table.AddColumn(
            AddOtherNet,
            "Other Weekly",
            each N([Column65]) - N([Column66]),
            Int64.Type
        ),


    // -------------------------------------------------------
    // OPEN INTEREST
    // -------------------------------------------------------

    AddOpenInterest =
        Table.AddColumn(
            AddOtherWeekly,
            "Open Interest",
            each N([Column8]),
            Int64.Type
        ),

    AddOIWeekly =
        Table.AddColumn(
            AddOpenInterest,
            "OI Weekly",
            each N([Column56]),
            Int64.Type
        ),


    // -------------------------------------------------------
    // FINAL DATA TABLE
    // -------------------------------------------------------

    FinalColumns =
        Table.SelectColumns(
            AddOIWeekly,
            {
                "Category",
                "Product",

                "Producer Net",
                "Producer Weekly",

                "Swap Net",
                "Swap Weekly",

                "Managed Money Net",
                "MM Weekly",

                "Record Long",
                "Record Short",

                "Other Net",
                "Other Weekly",

                "Open Interest",
                "OI Weekly",

                "Previous Report Date",
                "Report Date",

                "Sort"
            }
        ),


    // -------------------------------------------------------
    // SORT BY PRODUCT ORDER
    // -------------------------------------------------------

    Sorted =
        Table.Sort(
            FinalColumns,
            {
                {"Sort", Order.Ascending}
            }
        ),
    #"Added Custom" = Table.AddColumn(Sorted, "Date Range", each Date.ToText([Previous Report Date], "dd/MM/yyyy")
& " - " &
Date.ToText([Report Date], "dd/MM/yyyy"))

in
    #"Added Custom"
