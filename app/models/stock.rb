class Stock < ApplicationRecord
    has_many :investments
    has_many :portfolios, through: :investments
    after_create :get_stock_price_now


    def self.current_date_to_YYYYMMDD
        month = 0
        day = 0
        if Time.now.month < 10
            month = 0.to_s + "#{Time.now.month}"
        else
            month = Time.now.month
        end
        if Time.now.day < 10
            day = 0.to_s + "#{Time.now.day}"
        else
            day = Time.now.day
        end
        "#{Time.now.year}-#{month}-#{day}"
    end
        ####Returns current stock data (hash table)
    def self.get_current_stock_data(input)
        url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{input}&apikey=4NRHKKZWK1U7T0P1"
        response = RestClient.get(url)
        my_response = JSON.parse(response)
        if my_response["Error Message"] == "Invalid API call. Please retry or visit the documentation (https://www.alphavantage.co/documentation/) for TIME_SERIES_DAILY." || my_response["Note"] == "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency."
            false
        else
            daily_stock_info = my_response["Time Series (Daily)"][Stock.current_date_to_YYYYMMDD]
        end
    end

    
    ####Returns current stock price (float) - repeated code to avoid hitting the API twice for every request by using above function first
    def self.get_current_stock_price(input)
        url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=#{input}&apikey=4NRHKKZWK1U7T0P1"
        response = RestClient.get(url)
        my_response = JSON.parse(response)
        if my_response["Error Message"] == "Invalid API call. Please retry or visit the documentation (https://www.alphavantage.co/documentation/) for TIME_SERIES_DAILY." || my_response["Note"] == "Thank you for using Alpha Vantage! Our standard API call frequency is 5 calls per minute and 500 calls per day. Please visit https://www.alphavantage.co/premium/ if you would like to target a higher API call frequency."
            false
        else
            my_response["Time Series (Daily)"][current_date_to_YYYYMMDD]["1. open"].to_f
        end
    end


    def get_stock_price_now
        price = Stock.get_current_stock_price(self.ticker_symbol)
        self.update(current_price: price)
    end
end