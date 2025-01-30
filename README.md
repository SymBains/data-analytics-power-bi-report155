## Power BI Installation

 Create an Azure Virtual Machine (VM) running Windows. This setup is only for Mac or Linux users who need to run Power BI and do not have direct native access to the application. If you are on Windows you can skip this step. This Windows VM will server as your dedicated development environment for Power BI. Follow these steps to create a Windows VM:

1.  Create an Azure VM:

     - Sign up for an Azure free account (if you don’t have one)

    - Create a Windows Virtual Machine (VM) with the size D2s_v3

    - The Azure free trial provides a $200 credit, which covers this VM for the project duration
2. Connect to the Azure Windows VM:

     - Use Microsoft Remote Desktop (Mac/Linux users) to connect via RDP
3. Install Power BI Desktop:

     - Download and install Power BI Desktop for Windows from the official Microsoft website

## Importing Data 
### Orders Table (Main Fact Table)
This table contains information about each order, including dates, customers, stores, and product details.

1. Connect to Azure SQL Database:
    - Use the Import option in Power BI

2. Data Cleaning & Transformations:
    - Delete the [Card Number] column for privacy
    - Split Columns: Separate [Order Date] and [Shipping Date] into date and time
    - Filter Out Null Values: Remove rows with missing [Order Date]
    - Rename Columns: Ensure names follow Power BI naming conventions

### Products Table
This table includes product details like category, cost price, and sale price.

1. Import Data:
    - Download the Products.csv file
    - Use Get Data > CSV in Power BI to import

2. Data Cleaning & Transformations:
    - Remove Duplicates in [Product Code]
    - Rename Columns to align with Power BI standards

### Stores Table
This table contains store details such as store type, country, and region.

1. Import Data from Azure Blob Storage:

2. Data Cleaning & Transformations:
    - Ensure Region Names Are Consistent using the Replace Values tool
    - Rename Columns to maintain clarity and consistency

### Customers Table
This table contains customer details from multiple regions.

1. Import Data from Multiple CSV Files:
    - Download the Customers.zip file
    - Extract the folder containing three CSV files
    - Use Get Data > Folder in Power BI to import all files
    - Select Combine and Transform to append data into one query

2. Data Cleaning & Transformations:
    - Create a Full Name Column: Combine [First Name] and [Last Name]
    - Delete Unused Columns (e.g., index columns)
    - Rename Columns to match Power BI standards

## Data Model

1. Create a Date Table covering the full data range to leverage Power BI's time intelligence functions 
    - Use a DAX formula such as:
    ```
    Date = 
    ADDCOLUMNS(
    CALENDAR(
        DATE(YEAR(MIN(Orders[Order Date])), 1, 1),
        DATE(YEAR(MAX(Orders[Shipping Date])), 12, 31)
    ),
    "Day of Week", FORMAT([Date], "dddd"),
    "Month Number", MONTH([Date]),
    "Month Name", FORMAT([Date], "MMMM"),
    "Quarter", "Q" & QUARTER([Date]),
    "Year", YEAR([Date]),
    "Start of Year", DATE(YEAR([Date]), 1, 1),
    "Start of Quarter", DATE(YEAR([Date]), (QUARTER([Date]) - 1) * 3 + 1, 1),
    "Start of Month", DATE(YEAR([Date]), MONTH([Date]), 1),
    "Start of Week", [Date] - WEEKDAY([Date], 2) + 1
    )   
    ```
2.  Create Relationships for a Star Schema 

Establish one-to-many relationships as shown below:
![Alt text](https://i.postimg.cc/4NBqf3j2/Screenshot-2025-01-30-163548.png)
Ensure all relationships flow from the dimension table to the fact table.

3.  Create a separate Measures Table to organize measures: 
    - In Model View, select Enter Data
    - Create a blank table named Measures Table

4. Create Key Measures
- Add the following DAX measures:

    - Total Orders
    ```
    Total Orders = COUNTROWS(Orders)
    ```

    - Total Revenue
    ```
    Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))
    ```

    - Total Profit
    ```
    Total Profit = SUMX(Orders, (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])) * Orders[Product Quantity])
    ```
    - Total Customers
    ```
    Total Customers = DISTINCTCOUNT(Orders[User ID])
    ```
    - Total Quantity 
    ```
    Total Quantity = SUM(Orders[Product Quantity])
    ```
    - Profit YTD
    ```
    Profit YTD = TOTALYTD([Total Profit], Orders[Order Date])
    ```
    - Revenue YTD 
    ``` 
    Revenue YTD = TOTALYTD([Total Revenue],Orders[Order Date])
    ```
5. Create Hierarchies
- Date Hierarchy 
    - Start of Year
    - Start of Quarter
    - Start of Month
    - Start of Week
    - Date

- Geography Hierarchy 
    - Create a Country column in Stores:
    ```
    Country = SWITCH(Stores[Country Code], "GB", "United Kingdom", "US", "United States", "DE", "Germany")
    ```
    - Create a Geography column:
    ```
    Geography = Stores[Country Region] & ", " & Stores[Country]
    ```
    - Assign correct data categories:
        - Region: Continent
        - Country: Country
        - Country Region: State or Province
    - Hierarchy Levels:
        - World Region
        - Country
        - Country Region

## Setting up the Report
1. Create the following report pages:
    - Executive Summary
    - Customer Detail
    - Product Detail
    - Stores Map

2. Choose a colour theme

3. Add a Navigation Bar
- On the Executive Summary page:
    - Add a rectangle shape covering a narrow strip on the left
    - Set a contrasting fill color
- Copy and Paste the rectangle onto all other pages

## Customer Detail Page
1. Create Summary Cards
    - Create two rectangles and arrange them in the top left corner of the page. These will serve as the backgrounds for the card visuals
    - Add a card visual for the [Total Customers] measure we created earlier. Rename the field Unique Customers via the Visualizations pane (Format your visual tab > General > Title)
    - Create a new measure in your Measures Table called [Revenue per Customer], calculated as:
    ```
    Revenue per Customer = [Total Revenue]/[Total Customers]
    ```
    - Add a card visual for the [Revenue per Customer] measure

2. Create Donut Charts
    - Add a Donut Chart visual showing the total customers for each country, using the Customers[Country] column to filter the [Total Customers] measure
    - Add a Donut Chart visual showing the number of customers who purchased each product category, using the Products[Category] column to filter the [Total Customers] measure

3. Add a Line Chart
    - Add a Line Chart visual to the top of the page
        - Y-axis: [Total Customers]
        - X-axis: Use the Date Hierarchy created earlier
        - Allow users to drill down to the month level, but not to weeks or individual dates
    - Add a trend line and a forecast for the next 10 periods with a 95% confidence interval

4. Create a Top Customer Table
    - Create a table visual displaying the top 20 customers, filtered by revenue.
    - The table should show:
        - Customer's full name
        - Revenue
        - Number of orders
    - Add conditional formatting to the revenue column to display data bars for the revenue values

5. Highlight the top customer 
Create a set of three card visuals that provide insights into the top customer by revenue:
    - Top customer's name
    - Number of orders made by the customer
    - Total revenue generated by the customer

6. Add a Date Slicer
    - Add a date slicer to allow users to filter the page by year, using the between slicer style

The finished page should look as shown below:
![Alt text](https://i.postimg.cc/6QXBRq5V/Screenshot-2025-01-30-181608.png)

## Executive Summary Page
1. Create Summary Cards
    - Copy one of the grouped card visuals from the Customer Detail page and paste it onto the Executive Summary page
    - Duplicate it two more times and arrange the three cards so that they span about half of the width of the page
    - Assign them to the Total Revenue, Total Orders, and Total Profit measures.
    - Use the Format > Callout Value pane to ensure:
        - No more than 2 decimal places for Revenue and Profit
        - Only 1 decimal place for Total Orders

2. Add a Revenue Trending Line Chart
    - Copy the line chart from the Customer Detail page and modify it as follows:
        - X-axis: Date Hierarchy, displaying only Start of Year, Start of Quarter, and Start of Month levels
        - Y-axis: Total Revenue
    - Position the line chart just below the summary cards

3. Create Donut Charts
    - Add a Donut Chart visual showing Total Revenue broken down by Store[Country].
    - Add another Donut Chart visual showing Total Revenue broken down by Store[Store Type]
    - Position both charts to the right of the summary cards

4. Create a Bar Chart for Product Categories
    - Copy the Total Customers by Product Category donut chart from the Customer Detail page
    - In the On-Object Build a Visual pane, change the visual type to Clustered Bar Chart
    - Change the X-axis field from Total Customers to Total Orders
    - With the Format pane open, click on one of the bars to bring up the Colors tab and select an appropriate color matching your theme

5. Create KPIs for Quarterly Performance
    - Create new measures for the following:
        - Previous Quarter Profit
        ```
        Previous Quarter Profit = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarter = QUARTER(LatestOrderDate)
        VAR PreviousQuarterStart = SWITCH(TRUE(),
            CurrentQuarter = 1, DATE(YEAR(LatestOrderDate) - 1, 10, 1),
            CurrentQuarter = 2, DATE(YEAR(LatestOrderDate), 1, 1),
            CurrentQuarter = 3, DATE(YEAR(LatestOrderDate), 4, 1),
            DATE(YEAR(LatestOrderDate), 7, 1))
        RETURN CALCULATE([Total Profit], 'Date'[Start of Quarter] = PreviousQuarterStart)
        ```
        - Previous Quarter Revenue
        ```
        Previous Quarter Revenue = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarter = QUARTER(LatestOrderDate)
        VAR PreviousQuarterStart = SWITCH(TRUE(),
            CurrentQuarter = 1, DATE(YEAR(LatestOrderDate) - 1, 10, 1),
            CurrentQuarter = 2, DATE(YEAR(LatestOrderDate), 1, 1),
            CurrentQuarter = 3, DATE(YEAR(LatestOrderDate), 4, 1),
            DATE(YEAR(LatestOrderDate), 7, 1))
        RETURN CALCULATE([Total Revenue], 'Date'[Start of Quarter] = PreviousQuarterStart)
        ```
        - Previous Quarter Orders
        ```
        Previous Quarter Orders = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarter = QUARTER(LatestOrderDate)
        VAR PreviousQuarterStart = SWITCH(TRUE(),
            CurrentQuarter = 1, DATE(YEAR(LatestOrderDate) - 1, 10, 1),
            CurrentQuarter = 2, DATE(YEAR(LatestOrderDate), 1, 1),
            CurrentQuarter = 3, DATE(YEAR(LatestOrderDate), 4, 1),
            DATE(YEAR(LatestOrderDate), 7, 1))
        RETURN CALCULATE([Total Orders], 'Date'[Start of Quarter] = PreviousQuarterStart)
        ```
        - Target Revenue
        ```
        Target Revenue = [Previous Quarter Revenue] * 1.05
        ```
        - Target Profit
        ```
        Target Profit = [Previous Quarter Profit] * 1.05
        ```
        - Target Orders 
        ```
        Target Orders = [Previous Quarter Orders] * 1.05
        ```
    - Add a KPI visual for Revenue:
        - Value field: Total Revenue
        - Trend Axis: Start of Quarter
        - Target: Target Revenue
        - In the Format pane, set:
            - Trend Axis: On
            - Direction: High is Good
            - Bad Color: Red
            - Transparency: 15%
            - Callout Value: Show only 1 decimal place.
    - Duplicate the KPI visual two more times and set them for Total Profit and Total Orders
    - Arrange the three KPIs below the Revenue Trending Line Chart

The finished page should look as shown below:
![Alt text](https://i.postimg.cc/k4zkWMxF/Screenshot-2025-01-30-201537.png)

## Product Detail Page
1. Add Gauge Charts
    - Define DAX measures for:
        - Current Quarter Orders, Revenue, Profit.
        ```
        Current Quarter Orders = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarterStart = DATE(YEAR(LatestOrderDate), (QUARTER(LatestOrderDate) - 1) * 3 + 1, 1)
        RETURN CALCULATE([Total Orders], 'Date'[Start of Quarter] = CurrentQuarterStart)
        
        Current Quarter Profit = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarterStart = DATE(YEAR(LatestOrderDate), (QUARTER(LatestOrderDate) - 1) * 3 + 1, 1)
        RETURN CALCULATE([Total Profit], 'Date'[Start of Quarter] = CurrentQuarterStart)

        Current Quarter Revenue = 
        VAR LatestOrderDate = MAX(Orders[Order Date])
        VAR CurrentQuarterStart = DATE(YEAR(LatestOrderDate), (QUARTER(LatestOrderDate) - 1) * 3 + 1, 1)
        RETURN CALCULATE([Total Revenue], 'Date'[Start of Quarter] = CurrentQuarterStart)
        ```
        - Target values (10% quarter-on-quarter growth)
        - Gap between actual performance and target
        ```
        Gap Orders = [Current Quarter Orders] - [Current Target Orders]
        ```
    - Create three Gauge Charts, setting the maximum value to the target.
    - Apply conditional formatting:
        - Red if the target is not met
        - Black if the target is met
    - Arrange them evenly along the top of the page
2. Create Filter State Cards
    - Add two rectangle shapes
    - Define DAX measures:
    ```
    Category Selection = IF(ISFILTERED(Products[Category]), SELECTEDVALUE(Products[Category], "No Selection"), "No Selection")
    
    Country Selection = IF(ISFILTERED(Stores[Country]), SELECTEDVALUE(Stores[Country], "No Selection"), "No Selection")
    ```
    - Add Card Visuals displaying these measures.
3. Create an Area Chart:
    - X-axis: Dates[Start of Quarter]
    - Y-axis: Total Revenue
    - Legend: Products[Category]
- Position it to the left of the page.
4. Create a Top 10 Products Table
    - Copy the Top Customers Table from the Customer Detail page.
    - Adjust fields to show:
        - Product Description, Total Revenue, Total Customers, Total Orders, Profit per Order
5. Add a Scatter Chart for Product Profitability
    - Create a calculated column:
    ```
    Profit per Item = [Total Profit] / [Total Quantity]
    ```
    - Add a Scatter Chart:
        - X-axis: Profit per Item
        - Y-axis: Orders[Total Quantity]
        - Legend: Products[Category]

6. Create a Pop-Out Slicer Toolbar
    - Add a custom icon button for filters
    - Create a slicer panel and configure bookmarks
    -  Assign actions to Open and Close slicer panel buttons
A toolbar should look as follows:
![Alt text](https://i.postimg.cc/9MgqpKMB/Screenshot-2025-01-30-205253.png)

The finished page should look as shown below:
![Alt text](https://i.postimg.cc/gjwLBsLb/Screenshot-2025-01-30-205321.png)

## Stores Map Page
1. Create the Map Visual
    - Add a Map Visual to the Stores Map page
    - Resize it to take up the majority of the page, leaving only a narrow band at the top for a slicer
    - In the Format pane, adjust the style to fit the report theme and ensure Show Labels is set to On
    - Configure the map controls:
        - Auto-Zoom: On
        - Zoom Buttons: Off
        - Lasso Button: Off
    - Assign fields:
        - Location Field: Geography hierarchy
        - Bubble Size Field: Profit YTD 

2. Add a Country Slicer
    - Place a Slicer Visual above the map.
    - Assign Stores[Country] as the slicer field.
    - Format the slicer:
        - Style: Tile
        - Selection Settings:
        - Multi-select with Ctrl/Cmd
        - Show "Select All" option
A page should look as follows:
![Alt text](https://i.postimg.cc/B62n8zF6/Screenshot-2025-01-30-210344.png)

3. Create a Drillthrough Page for Store Performance
    - Add a new page and name it Stores Drillthrough
    - Open the Format pane > Page Information, then:
        - Set Page type to Drillthrough
        - Set Drill through when to Used as category
        - Set Drill through from to Country Region
    - Add the following visuals:
        - Top 5 Products Table:
            - Columns: Description, Profit YTD, Total Orders, Total Revenue
        - Column Chart:
            - X-axis: Product Category
            - Y-axis: Total Orders
        - Gauges for Profit YTD:
            - Set against a profit target of 20% year-over-year growth
            - Use Target Field, not Maximum Value
        - Card Visual:
            - Displays the currently selected store 

This drillthrough page should look like this:
![Alt text](https://i.postimg.cc/9MbsNt5b/Screenshot-2025-01-30-211231.png)

4. Create a Custom Tooltip for the Map
    - Create a Tooltip Page.
    - Copy over the Profit Gauge Visual from the drillthrough page.
    - Set the tooltip of the map visual to the newly created tooltip page.
    - Ensure that when users hover over a store, they see year-to-date profit performance against the profit target.

The map will look like this when hovering over a store:
![Alt text](https://i.postimg.cc/KYrWRrzb/Screenshot-2025-01-30-211615.png)

## Cross-Filtering and Navigation
From the Edit Interactions view in the Format tab of the ribbon, set the following interactions:
1. Executive Summary Page
    - Product Category bar chart and Top 10 Products table should not filter the card visuals or KPIs
2. Customer Detail Page
    - Top 20 Customers table should not filter any of the other visuals 
    - Total Customers by Product Category Donut Chart should not affect the Customers line graph 
    - Total Customers by Country donut chart should cross-filter Total Customers by Product Category Donut Chart
3. Product Detail Page
    - Orders vs. Profitability scatter graph should not affect any other visuals 
    - Top 10 Products table should not affect any other visuals

## SQL Metrics
It is common for clients to not have direct access to Power BI. To ensure data insights can still be extracted SQL queries can be used as an additional tool in the data analysis toolkit.
1.  Connect to the Postgres database server hosted on Microsoft Azure. To connect to the server and run queries from VSCode, you will need to install the SQLTools extension. 
2. You can then connect to the server with the details. Make sure to set SSL Encryption to enabled in the connection settings.

In the GitHub repository the following questions have been answered using SQL queries: 
1. How many staff are there in all of the UK stores?

2. Which month in 2022 has had the highest revenue?

3. Which German store type had the highest revenue for 2022?

4. Create a view where the rows are the store types and the columns are the total sales, percentage of total sales and the count of orders

5. Which product category generated the most profit for the "Wiltshire, UK" region in 2021?

The queries can be found as the .sql files and the answers in the .csv files. 


