require 'thor'
require_relative 'application'
require_relative 'skeleton.rb'
require_relative 'cli/main'

##
# Command Line User Interface
class CLI < Thor
  map ['h', '-h', '--help'] => 'help'

  map ['v', '-v', '--version'] => 'version'
  desc 'version', 'Show the program version'
  ##
  # Command: display version
  def version
    puts "#{Application::NAME} (version #{Application::VERSION})"
  end

  map ['c', '-c', '--create', 'create'] => 'new'
  desc 'new DIRECTORY', 'Create skeleton for a new project'
  long_desc <<-LONGDESC
  Create files for a new project.
  LONGDESC
  ##
  # Command: create new Teuton project
  def new(path_to_new_dir)
    Skeleton.create(path_to_new_dir)
  end

  ##
  # These inputs are equivalents:
  # * teuton dir/foo
  # * teuton run dir/foo
  # * teuton play dir/foo
  def method_missing(method, *_args, &_block)
    play(method.to_s)
  end

  ##
  # Respond to missing methods name
  def respond_to_missing?(method_name, include_private = false)
    super
  end
end
