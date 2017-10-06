library(flexdashboard)
library(tidyquant)
library(scales)
library(ggthemes)
library(broom)

#plots
input_tickers <- list(c('VTI', 'VNQ', 'VGK', 'EXC', 'VNQ', 'VNQ', 'VNQ'))
input_tickers <- unlist(input_tickers)
input_tickers[length(input_tickers)+1] <- 'SPY'

input_dates <- as.Date(c('2016-01-09', '2015-10-20', '2016-06-06', '2016-01-19', '2016-01-20', '2016-02-05', '2016-02-08'))
input_dates <- c(input_dates, min(input_dates))

input_shares <- c(95,20,90,175,15,30,25)
input_shares[length(input_shares)+1] <- 1

input_prices <- c(95.31, 80.95, 45.56, 27.40, 73.17, 76.11, 72.27)
input_prices[length(input_prices)+1] <- 0


plot_dat <- tibble()

for(i in 1:length(input_tickers)){
    tickeri <- input_tickers[i]
    datei <- input_dates[i]
    sharei <- input_shares[i]
    pricei <- input_prices[i]

    tmp <- tq_get(tickeri, get = "stock.prices", from = datei) %>%
        mutate(ticker = tickeri, shares = sharei, purchase_price = pricei,
               flag = ifelse(ticker == 'SPY', 'benchmark', 'portfolio'))

   tmp <- tmp %>%
       arrange(date) %>%
       mutate(purchase_price = ifelse(purchase_price == 0, close[1], purchase_price),
              initial_value = shares*purchase_price,
              initial_adjustment = close[1] - adjusted[1],
              adjustment = initial_adjustment - (close - adjusted),
              total_return = shares*(close + adjustment) - initial_value,
              pct_total_return = total_return/initial_value) %>%
       ungroup()

   plot_dat <- rbind(plot_dat, tmp)
   
}


plot_dat %>%
    group_by(flag, date) %>%
    summarize(total_return = sum(total_return),
              initial_value = sum(initial_value),
              pct_total_return = total_return/initial_value) %>%
    ggplot(aes(x = date, y = pct_total_return, color = flag)) + geom_line() +
    ggtitle("Portfolio total return vs benchmark (SPY)") +
    theme_tufte(base_family = 'Tahoma') +
    theme(panel.grid.major = element_line(size = 0.1, color = "grey"),
          axis.text.y = element_text(size = 10),
          axis.text.x = element_text(size = 10),
          axis.title.x = element_blank(), axis.title.y=element_blank(),
          plot.title = element_text(hjust = 0.5, face = 'bold'),
          legend.position = 'left', legend.title = element_blank(),
          legend.text = element_text(size = 12)) +
    scale_y_continuous(labels = scales::percent, position = 'right')



#table

input_tickers <- list(c('VTI', 'VNQ', 'VGK', 'EXC', 'VNQ', 'VNQ', 'VNQ'))
input_tickers <- unlist(input_tickers)

input_dates <- as.Date(c('2016-01-09', '2015-10-20', '2016-06-06', '2016-01-19', '2016-01-20', '2016-02-05', '2016-02-08'))

input_shares <- c(95,20,90,175,15,30,25)

input_prices <- c(95.31, 80.95, 45.56, 27.40, 73.17, 76.11, 72.27)



return_dat <- tibble()

for(i in 1:length(input_tickers)){
    tickeri <- input_tickers[i]
    datei <- input_dates[i]
    sharesi <- input_shares[i]
    pricei <- input_prices[i]
    
    tmp <- tq_get(tickeri, get = "stock.prices", from = datei) %>%
        filter(date == min(date) | date == max(date)) %>%
        arrange(date) %>%
        summarise(ticker = tickeri, shares = sharesi,
            current_price = close[2],
            purchase_price = ifelse(pricei == 0, close[2], pricei),
            initial_value = sharesi*purchase_price,
            current_value = sharesi*close[2],
            initial_value_adj = sharesi*(adjusted[1] - (close[1] - purchase_price)),
            total_return = current_value - initial_value_adj,
            price_return = current_value - initial_value,
            div_return = total_return - price_return,
            delta_days = as.numeric(max(date) - min(date)))
    
    return_dat <- rbind(return_dat, tmp)
    
}


return_dat_disp <- return_dat %>%
    group_by(ticker) %>%
    summarise(total_shares = sum(shares),
              current_price = min(current_price),
              current_value = sum(current_value),
              initial_value = sum(initial_value),
              initial_value_adj = sum(initial_value_adj),
              total_return = sum(total_return), 
              price_return = sum(price_return),
              div_return = sum(div_return),
              delta_days = sum(delta_days*shares)/sum(shares)) %>%
    ungroup() %>%
    mutate(weight = percent_func(current_value/sum(current_value)),
           `purchase price` = dollar(initial_value/total_shares),
           `current price` = dollar(current_price),
           `current value` = dollar(round(current_value, digits = 0)),
           `total return` = dollar(round(total_return, digits = 0)),
           `% total return` = percent_func(total_return/initial_value),
           `% price return` = percent_func(price_return/initial_value),
           `% div return` = percent_func(div_return/initial_value),
           `% div AR` = percent_func((1 + (div_return/initial_value))^(365/delta_days) - 1),
           `% total AR` = percent_func((1 + (total_return/initial_value))^(365/delta_days) - 1)) %>%
    select(ticker, weight, `purchase price`, `current price`, `current value`, `total return`,
           `% total return`, `% price return`, `% div return`, `% total AR`, `% div AR`)
