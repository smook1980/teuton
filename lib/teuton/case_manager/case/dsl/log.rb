require "rainbow"
##
# Define DSL#log function
module DSL
  ##
  # Record log message
  # @param text (String)
  # @param type (Symbol) Values :info, :warn or :error
  def log(text = "", type = :info)
    s = " INFO"
    s = Rainbow("WARN!").color(:yellow) if type == :warn
    s = Rainbow("ERROR").bg(:red) if type == :error
    t = Time.now
    f = format("%<hour>02d:%<min>02d:%<sec>02d", {hour: t.hour, min: t.min, sec: t.sec})
    msg = "[#{f}] #{s}: #{text}"
    msg = "[#{f}] #{text}" if s == ""
    @report.lines << msg
  end
  alias msg log
end
