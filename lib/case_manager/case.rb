require_relative '../application'
require_relative '../report/report'
require_relative 'utils'
require_relative 'case/main'

# TODO: split Case class into several classes:
# * Case, Action?, Session?, RunCommand class

# Case class
class Case
  include DSL
  include Utils

  attr_accessor :result, :action
  attr_reader :id, :config, :report, :uniques
  @@id = 1

  def initialize(p_config)
    app = Application.instance
    @config = Case::Config.new(local: p_config, global: app.global)

    @groups = app.groups
    @id = @@id
    @@id += 1

    # Define Case Report
    @report = Report.new(@id)
    @report.output_dir = File.join('var', @config.global[:tt_testname], 'out')
    ensure_dir @report.output_dir

    # Default configuration
    @config.local[:tt_skip] = @config.local[:tt_skip] || false
    @mntdir = File.join('var', @config.get(:tt_testname), 'mnt', @id.to_s)
    @tmpdir = File.join('var', @config.get(:tt_testname), 'tmp')
    @remote_tmpdir = File.join('/', 'tmp')

    ensure_dir @mntdir
    ensure_dir @tmpdir

    @unique_values = {}
    @result = Result.new

    @debug = Application.instance.debug
    @verbose = Application.instance.verbose

    @action_counter = 0
    @action = { id: 0, weight: 1.0, description: 'No description!' }
    @uniques = []
    @sessions = {}
    tempfile :default
  end

  def skip
    @config.get(:tt_skip)
  end

  private

  def read_filename(filename)
    begin
      file = File.open(filename, 'r')
      item = file.readlines
      file.close

      item.map! { |i| i.sub(/\n/, '') }

      return item
    rescue
      return []
    end
  end
end
