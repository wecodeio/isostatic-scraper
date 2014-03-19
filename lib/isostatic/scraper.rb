require "mechanize"

require_relative "version"

module Isostatic
  class Scraper
    BASE_URL = "http://bearing-solutions.isostatic.com".freeze
    ITEM_URL = "#{BASE_URL}/keyword/?&plpver=10&key=all&keycateg=100&SchType=2&keyword=:keyword".freeze
    IMAGE_SRC_REGEXP = %r(/ImgMedium/)
    KEYS_SELECTOR = "h2.text1".freeze
    VALUES_SELECTOR = "td.tablebg2 > span.text1".freeze
    WEIGHT_KEY = "Avg Unit Weight".freeze
    INTERCHANCE_PART_NUMBER_REGEXP = /[A-Z0-9 -]{2,}/
    INTERCHANCE_PART_KEY = "Interchange #".freeze
    MORE_THAN_ONE_ITEM_MATCHED_TEXT = "Check up to five results to perform an action".freeze
    ITEM_LINK_REGEXP = %r(/item/)

    def initialize(part_number)
      @part_number = CGI.escape(part_number)
    end

    def image_url
      @image_url ||= begin
        image = item_page.image_with(src: IMAGE_SRC_REGEXP)
        return unless image
        image_name = image.url.path.split("/").last
        "#{BASE_URL}/Asset/#{image_name}"
      end
    end

    def aux_data
      @aux_data ||= begin
        keys = item_page.search(KEYS_SELECTOR).to_a.map!(&:text)
        values = item_page.search(VALUES_SELECTOR).to_a

        if interchange_part_number_index = keys.index(INTERCHANCE_PART_KEY)
          keys.delete(INTERCHANCE_PART_KEY)
          interchange_part_number_value = values.delete_at(interchange_part_number_index)
          interchange_part_numbers = interchange_part_number_value.to_s.scan(INTERCHANCE_PART_NUMBER_REGEXP)
        end

        values.map!(&:text)

        if interchange_part_number_index
          keys << INTERCHANCE_PART_KEY
          values << interchange_part_numbers
        end

        Hash[keys.zip(values)].tap { |hash| @weight = hash.delete(WEIGHT_KEY) }
      end
    end

    def weight
      aux_data && @weight
    end

  private

    def item_page
      @item_page ||= begin
        agent = Mechanize.new
        item_url = ITEM_URL.sub(":keyword", @part_number)
        page = agent.get(item_url)

        if page.body[MORE_THAN_ONE_ITEM_MATCHED_TEXT]
          links = page.search("#spanItemResults a.text2").select { |a| a["href"] =~ ITEM_LINK_REGEXP }
          items = links.map { |link| link.parent.previous.previous.previous.text.rstrip }
          index = items.index(@part_number)
          return page unless index

          path = links[index]["href"]
          item_url = BASE_URL + path
          agent.get(item_url)
        else
          page
        end
      end
    end
  end
end


