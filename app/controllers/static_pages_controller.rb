class StaticPagesController < ApplicationController

  def index
    @locations = Location.all
  end

  def update
    require 'nokogiri'
    require 'open-uri'

    doc = Nokogiri::XML(open("http://www.related.com/feeds/ZillowAvailabilities.xml"))

    @results = []

    doc.xpath('//Listing/Location').each do |listing|

      if location = Location.find_by_pid(listing.at_xpath('ZPID').text)
        if location.latitude == nil
          location.address = location.address + " "
          location.save!
          sleep(0.2)
        end
      else
        pid = listing.at_xpath('ZPID').text
        address = "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}"
        location = Location.new(pid: pid, address: address)
        location.save!
        sleep(0.2)
      end
      @results << location
    end

    ###############################################################################

    url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    i = 0
    @results2 = []

    while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0

      doc = Nokogiri::HTML(open("#{url}#{i}"))

      doc.css('.listing').each do |listing|
        if location = Location.find_by_pid(listing.attributes['data-listingid'].text)
          if location.latitude == nil
            location.address = location.address + " "
            location.save!
            sleep(0.2)
          end
        else
          location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
          sleep(0.2)
          location.save!
        end
        @results2 << location
      end
      i+=1
    end
  end
end
