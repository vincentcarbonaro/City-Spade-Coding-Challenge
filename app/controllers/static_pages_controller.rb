class StaticPagesController < ApplicationController

  def index
    @locations = Location.all
  end

  def update
    require 'nokogiri'
    require 'open-uri'

    ################################################################################

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []

    doc.xpath('//Listing/Location').each do |listing|

      if location = Location.find_by_pid(listing.at_xpath('ZPID').text)
        @results << location
      else
        location = Location.new(pid: listing.at_xpath('ZPID').text, address: "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}")
        location.save!
        @results << location
      end

    end

    ################################################################################

    url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    i = 0
    @results2 = []

    while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0

      doc = Nokogiri::HTML(open("#{url}#{i}"))

      doc.css('.listing').each do |listing|
        location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
        location.save!
        @results2 << location
      end
    #
      i+=1
    end

    # Users of the free API:
    # 2,500 requests per 24 hour period.
    # 5 requests per second.

  end

  def FULLUPDATE
    require 'nokogiri'
    require 'open-uri'

    ################################################################################

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []

    doc.xpath('//Listing/Location').each do |listing|

      if location = Location.find_by_pid(listing.at_xpath('ZPID').text)
      else
        location = Location.new(pid: listing.at_xpath('ZPID').text, address: "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}")
        location.save!
      end

      @results << location

    end

    ################################################################################

    url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    i = 23
    @results2 = []

    while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0

      doc = Nokogiri::HTML(open("#{url}#{i}"))

      doc.css('.listing').each do |listing|

        if location = Location.find_by_pid(listing.attributes['data-listingid'].text)
        else
          location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
          location.save!
        end

        @results2 << location
      end

      i+=1
    end
  end

end
