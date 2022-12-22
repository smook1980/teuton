# frozen_string_literal: true

require "rainbow"
require "singleton"
require_relative "../application"
require_relative "../report/report"
require_relative "../report/show"
require_relative "../utils/configfile_reader"
require_relative "case/case"
require_relative "export_manager"
require_relative "main"

# This class does all the job
# Organize the hole job, sending orders to others classes
# * initialize
# * play
# Split into several files:
# * case_manager/check_cases
# * case_manager/export
# * case_manager/hall_of_fame
# * case_manager/report
class CaseManager
  include Singleton
  include Utils
  attr_reader :report, :cases

  def initialize
    @cases = []
    @report = Report.new(0)
    @report.filename = "resume"
  end

  ##
  # Execute "play" order: Start every single case test
  # @param block (Block)
  def play(&block)
    check_cases!
    instance_eval(&block)
    # Run export if user pass option command "--export=json"
    i = Application.instance.options["export"]
    export(format: i.to_sym) unless i.nil?
    # Accept "configfile" param REVISE There exists?
    i = Application.instance.options["configfile"]
    export(format: i.to_sym) unless i.nil?
  end

  ##
  # Execute "export" order: Export every case report
  # @param args (Hash) Export options
  def export(args = {})
    if args.class != Hash
      puts "[ERROR] CaseManager#export: Argument = <#{args}>, " \
           "class = #{args.class}"
      puts "        Usage: export format: :colored_text"
      raise "[ERROR] CaseManager#export: Argument error!"
    end
    # Export report files
    ExportManager.run(@report, @cases, args)
  end

  ##
  # Execute "send" order: Send every case report
  # @param args (Hash) Send options
  def send(args = {})
    threads = []
    puts ""
    puts Rainbow("[INFO] Sending files...#{args}").green
    @cases.each { |c| threads << Thread.new { c.send(args) } }
    threads.each(&:join)
  end

  def show(options = {verbose: 1})
    verbose = options[:verbose]
    return if Application.instance.quiet?

    # Show resume report data on screen
    ShowReport.new(@report).call(verbose)
  end
end
