class StaticPagesController < ApplicationController

  class Listing
    attr_accessor :id, :address
  end

  def root
    require 'nokogiri'
    require 'open-uri'

    ################################################################################

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []

    doc.xpath('//Listing/Location').each do |listing|
      instance = Listing.new
      instance.id = listing.at_xpath('ZPID').text + " "
      instance.address = "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}"
      @results << instance
    end

    ################################################################################

    url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    i = 26
    @results2 = []

    while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0

      doc = Nokogiri::HTML(open("#{url}#{i}"))

      doc.css('.info').each do |anchor|
        instance = Listing.new
        instance.id = Hash[anchor.xpath("//a/@*[starts-with(name(), 'data-')]").map{|e| [e.name,e.value]}]['data-listingid'] + " "
        instance.address = anchor.css('.address').text.strip + " " + anchor.css('.hood').text.strip
        @results2 << instance
      end

      i+=1
    end

    # Users of the free API:
    # 2,500 requests per 24 hour period.
    # 5 requests per second.

  end
end
