require 'tracker/api/builder'
require 'tracker/api/formatter'
require 'tracker/api/implementation'
require 'nokogiri'
require 'net/http'

module Tracker
  module Api
    # ヤマト運輸
    # @see http://toi.kuronekoyamato.co.jp/cgi-bin/tneko
    class Yamato
      include Tracker::Api::Implementation

      def build_param
        @data = {}
        @data["number00"] = 1
        @data["number01"] = @no

        self
      end

      def create_form
        self
      end

      def send_data
        host = "http://toi.kuronekoyamato.co.jp/cgi-bin/tneko"
        uri = URI.parse(host)
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Post.new uri.path
          req.set_form_data @data
          http.request(req)
        end
        @html = res.body

        self
      end

      def parse_data
        @build = Tracker::Api::Builder.new
        @doc = Nokogiri::HTML.parse(@html, nil, "CP932") do |config|
          config.noblanks
        end

        # 最新の情報を取得する
        @doc.search('table[@class="saisin"]').each do |node|
          node.search('tr').each_with_index do |tr, i|
            case i
            when 0
              # img X件目 伝票番号
              @build.no = @no
            when 1
              # br br status
              @build.status = tr.css('td').text
            when 2
              # desc1
              @build.description = tr.css('td').text
            when 3
              # desc2
              #@build.description = tr.css('td').text
            end
          end
        end

        # 明細行があればすべての明細を取得する
        @doc.search('table[@class="meisai"]').each do |node|
          node.css('tr').each do |tr|

            build = Tracker::Api::Builder.new
            build.no = @no
            tr.css('td').each_with_index do |n, i|
              case i
              when 0 #経過
              when 1 #状態
                build.status = n.text
              when 2 #日付
                build.date = n.text
              when 3 #時刻
                build.time = n.text
              when 4 #担当店名
                build.place = n.text
              when 5 #担当店コード
                build.description = n.text
              end
            end
            build.company = "yamato"

            @details << build.object_to_hash
          end
        end

        self
      end

      def format_data
        @build.company = "yamato"
        @build.date ||= Date.today.to_s
        @build.time ||= Time.now.strftime("%H:%M:%S")
        @build.place = "" #荷物の場所
        @build.description = "最新"
        @details << @build.object_to_hash

        self
      end
    end
  end
end
