class StaticPagesController < ApplicationController

  def root
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []

    doc.xpath('//Listing/Location').each do |listing|
      @results << "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}"
    end

    doc = Nokogiri::HTML(open("http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent"))

    @results2 = []

    doc.css('.info').each do |anchor|
      @results2 << anchor.css('.address').text.strip + " " + anchor.css('.hood').text.strip
    end

  end

end
