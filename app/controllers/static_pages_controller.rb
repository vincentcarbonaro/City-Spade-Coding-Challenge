class StaticPagesController < ApplicationController

  def index
    @locations = Location.all
  end

  def update
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []
    z = 0;

    doc.xpath('//Listing/Location').each do |listing|


      if location = Location.find_by_pid(listing.at_xpath('ZPID').text)
        if location.latitude == nil
          location.address = location.address + " "
          location.save!
        end
        @results << location
      else

        pid = listing.at_xpath('ZPID').text
        address = "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}"

        location = Location.new(pid: pid, address: address)

        location.save!

        sleep(0.3)
        @results << location

      end

      z+=1

    end

  # http://quotaguard2720:700399cf9303@proxy.quotaguard.com:9292
  # heroku config -s | grep http://quotaguard2720:700399cf9303@proxy.quotaguard.com:9292 >> .env

    ################################################################################

    # url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    # i = 26
    # @results2 = []
    #
    # while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0
    #
    #   doc = Nokogiri::HTML(open("#{url}#{i}"))
    #
    #   doc.css('.listing').each do |listing|
    #     location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
    #     location.save!
    #     fail
    #     @results2 << location
    #   end
    #
    #   i+=1
    # end

    # Users of the free API:
    # 2,500 requests per 24 hour period.
    # 5 requests per second.

  end

  ############################################################################################################

  def FULLUPDATE
    require 'nokogiri'
    require 'open-uri'
    require 'net/http' #needed for making requests (to google api)
    require 'json' #needed for parsing JSON responses

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
    i = 22
    @results2 = []

    while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0

      doc = Nokogiri::HTML(open("#{url}#{i}"))

      doc.css('.listing').each do |listing|

        if location = Location.find_by_pid(listing.attributes['data-listingid'].text)
        else
          location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
          location.save!
          fail
        end

        @results2 << location
      end

      i+=1
    end
  end

end
