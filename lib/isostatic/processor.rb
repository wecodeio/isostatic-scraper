require "csv"
require "logger"
require "thread_safe"

require_relative "scraper"

module Isostatic
  class Processor
    PRODUCT_ID_REGEXP = /\A\d+\z/
    MAX_CONCURRENCY = 100

    attr_accessor :output_dir, :max_concurrency

    def initialize
      yield(self)
    end

    def run(csv)
      logger = Logger.new(STDOUT)
      arr_of_arrs = CSV.parse(csv)
      arr_of_arrs.select! { |arr| arr.first =~ PRODUCT_ID_REGEXP && !arr.last.empty? }
      queue = Thread::Queue.new
      arr_of_arrs.each { |arr| queue << arr }
      arr_of_arrs = nil

      images_file_path = File.join(output_dir, "images.csv")
      aux_data_file_path = File.join(output_dir, "aux_data.csv")
      weights_file_path = File.join(output_dir, "weights.csv")

      CSV.open(images_file_path, "wb") do |images_file|
        CSV.open(aux_data_file_path, "wb") do |aux_data_file|
          CSV.open(weights_file_path, "wb") do |weights_file|
            images_file << %w(ID NAME IMAGE)
            images_file << []

            aux_data_file << ["ID", "NAME", "AUX DATA"]
            aux_data_file << []

            weights_file << %w(ID NAME WEIGHT)
            weights_file << []

            threads = (1..[queue.size, max_concurrency].min).map do |i|
              Thread.new(i) do |i|
                arr = begin
                        queue.pop(true)
                      rescue ThreadError; end

                while arr
                  product_id, part_number = arr
                  logger.debug "[Thread ##{i}] - part number: #{part_number}"
                  scraper = Scraper.new(part_number)
                  image_url = scraper.image_url
                  images_file << [product_id, part_number, image_url]

                  aux_data = scraper.aux_data
                  interchange_part_numbers = aux_data.delete(Scraper::INTERCHANCE_PART_KEY)
                  data = aux_data.flatten
                  if interchange_part_numbers
                    data << Scraper::INTERCHANCE_PART_KEY << interchange_part_numbers.join(" | ")
                  end
                  data.unshift(product_id, part_number)
                  aux_data_file << data

                  weight = scraper.weight
                  weights_file << [product_id, part_number, weight]

                  arr = begin
                          queue.pop(true)
                        rescue ThreadError; end
                end
              end
            end
            threads.each(&:join)
          end
        end
      end
    end
  end
end
