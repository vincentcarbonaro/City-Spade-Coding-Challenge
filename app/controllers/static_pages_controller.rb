# https://maps.googleapis.com/maps/api/geocode/json?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&key=AIzaSyDzJuQL5GR4pzHRpsXlZZ9Z4_soBHGlXys

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

      next if z > 0

      if location = Location.find_by_pid(listing.at_xpath('ZPID').text)
        @results << location
      else

        pid = listing.at_xpath('ZPID').text
        address = "#{listing.at_xpath('StreetAddress').text} #{listing.at_xpath('City').text} #{listing.at_xpath('State').text} #{listing.at_xpath('Zip').text}"

        google_api_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=AIzaSyDzJuQL5GR4pzHRpsXlZZ9Z4_soBHGlXys"
        resp = Net::HTTP.get_response(URI.parse(google_api_url))
        data = JSON.parse(resp.body)

        sleep(0.2)

        location = Location.new(
          pid: pid,
          address: address,
          latitude: data["results"][0]["geometry"]["location"]["lat"],
          longitude: data["results"][0]["geometry"]["location"]["lng"]
        )

        location.save!
        @results << location

      end

      z+=1

    end

    ################################################################################

    # url = "http://www.corcoran.com/nyc/Search/Listings?SaleType=Rent&&Count=36&Page="
    # i = 0
    @results2 = []

    # while Nokogiri::HTML(open("#{url}#{i}")).css('.info').length > 0
    #
    #   doc = Nokogiri::HTML(open("#{url}#{i}"))
    #
    #   doc.css('.listing').each do |listing|
    #     location = Location.new(pid: listing.attributes['data-listingid'].text, address: listing.css('.address').text.strip + " " + listing.css('.hood').text.strip)
    #     location.save!
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
