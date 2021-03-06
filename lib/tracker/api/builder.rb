require 'json'
module Tracker # :nodoc:
  module Api # :nodoc:
    class Builder
      # @return [String] 追跡番号
      attr_accessor :no

      # @return [String] ステータス
      # @note "entry" => "配送中", "reject" => "持戻", "complete" => "完了"
      # @note 各社でそれぞれ対応するものに置き換える
      attr_accessor :status

      # @!attribute date
      #   @return [String] 荷物の処理日付
      # @!attribute time
      #   @return [String] 荷物の処理時間
      # @!attribute place
      #   @return [String] 荷物の場所
      # @!attribute company
      #   @return [String] 配送会社
      # @!attribute description
      #   @return [String] 概要
      # @!attribute enabled
      #   @return [Boolean] レコードがゴミデータかどうか
      attr_accessor :date, :time, :place, :company, :description, :enabled
      
      # @return [Hash] フォーマット変換前の自身のオブジェクト
      attr_accessor :origin

      # @param args [Hash] "no" => "12345", "status" => "entry"
      # no: nil, status: nil, date: nil, time: nil, place: nil, company: nil, description: nil, enabled: false, origin: nil)
      def initialize(args={})
        @no = args["no"]
        @status = args["status"]
        @date = args["date"]
        @time = args["time"]
        @place = args["place"]
        @company = args["company"]
        @description = args["description"]
        @enabled = args["enabled"]
        @origin = args["origin"]
      end

      # 自身をJSONに変換する
      # @return [String]
      def object_to_json
        object_to_hash.to_json
      end

      # 自身をHashに変換する
      # @return [Array] [<Hash>, <Hash>]
      def object_to_hash
        data = {}
        self.instance_variables.each {|n| data[n.to_s.delete("@")] = self.instance_variable_get(n) }
        data
      end

      # 自身をoriginにコピーする。originにデータがある場合はコピーしない
      # @return [Hash] #origin
      def copy
        @origin ||= self.object_to_hash
      end
    end
  end
end
