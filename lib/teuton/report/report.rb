require_relative "../application"
require_relative "formatter/formatter"

class Report
  attr_accessor :id, :filename, :output_dir
  attr_accessor :head
  attr_accessor :lines
  attr_accessor :tail
  attr_reader :format
  attr_reader :history

  def initialize(id = "00")
    @id = id
    @filename = "case-#{@id}"
    @output_dir = Application.instance.output_basedir
    @head = {}
    @lines = []
    @tail = {}
    # @history save 1 letter for every target.
    # For example: "..F." means: good, good, fail and good
    # I will use this in the future stats manager.
    @history = ""
  end

  def export(format = :txt, options = {})
    @format = format
    filepath = File.join(@output_dir, @filename)
    Formatter.call(self, @format, filepath)
  end

  def export_resume(format = :txt, options = {})
    @format = "resume_#{format}".to_sym
    filepath = File.join(@output_dir, @filename)
    Formatter.call(self, @format, filepath)

    filepath = File.join(@output_dir, "moodle")
    Formatter.call(self, :moodle_csv, filepath)
  end

  ##
  # Calculate final values:
  # * grade
  # * max_weight
  # * good_weight,d
  # * fail_weight
  # * fail_counter
  def close
    app = Application.instance
    max = 0.0
    good = 0.0
    fail = 0.0
    fail_counter = 0
    @lines.each do |i|
      next unless i.instance_of? Hash

      max += i[:weight] if i[:weight].positive?
      if i[:check]
        good += i[:weight]
        @history += app.letter[:good]
      else
        fail += i[:weight]
        fail_counter += 1
        @history += app.letter[:bad]
      end
    end
    @tail[:max_weight] = max
    @tail[:good_weight] = good
    @tail[:fail_weight] = fail
    @tail[:fail_counter] = fail_counter

    i = good.to_f / max
    i = 0 if i.nan?
    @tail[:grade] = (100.0 * i).round
    @tail[:grade] = 0 if @tail[:unique_fault].positive?
  end
end
