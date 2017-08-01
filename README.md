## Portfolio total return dashboard

A portfolio's performance is often calculated as it's total price return - the difference between the iniital value and the current value. This method overlooks returns from other sources such as dividends and stock splits. This dashboard calculates a portfolio's total return by adjusting the initial value of each position for dividends and splits and then comparing the adjusted number to the current value. The portfolio's aggregate results are also compared to the total return of the S&P 500, as represented by the SPDR S&P 500 ETF from State Street (SPY).

### Instructions
Select the ticker symbol, purchase price & date, and the number of shares from the scrolling bar on the left. If the purchase price is left at zero, the closing price on the purchase date will be used.

Results are then displayed in two windows: a table of values at the top, and a comparison chart at the bottom.
1. Data table
	* ticker = ticker symbol for selected security
	* weight = percentage of the portoflio's current value
	* purchase price = the purchase price of the security
	* current price = the current price of the security (as of the date in the title bar)
	* current value = total current value of the position (# of shares * current price)
	* total return = the difference between the total current value and the dividend/split adjusted initial value
	* % total return = total return expressed as a percentage of iniital value (# of shares * purchase price)
	* % price return = the difference between the total current value and the initial value (unadjusted), expressed as a percentage of the initial value
	* % div return = the total of all additional returns beyond the price return (typically from dividends or splits), expressed as a percentage of the initial value
	* % total AR = annualized % total return: (1 + % total return)^(365/portfolio age in days) - 1
	* % div AR = annualized div return: (1 + % div return)^(365/portfolio age in days) - 1
1. Comparison chart
	* The aggregate performance of the portfolio (blue line), plotted against the SPY benchmark (red line)

This HTML dashboard was created with R and the flexdashboard library. To create a version to track your own portfolio, copy the dashboard.Rmd file and adjust the default values to match your portfolio positions.

Link to dashboard: https://davidldenton.shinyapps.io/portfolio_returns/