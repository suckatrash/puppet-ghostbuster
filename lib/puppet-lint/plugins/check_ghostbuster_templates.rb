require 'puppet-ghostbuster/puppetdb'

class PuppetLint::Checks
  def load_data(path, content)
    lexer = PuppetLint::Lexer.new
    PuppetLint::Data.path = path
    begin
      PuppetLint::Data.manifest_lines = content.split("\n", -1)
      PuppetLint::Data.tokens = lexer.tokenise(content)
      PuppetLint::Data.parse_control_comments
    rescue
      PuppetLint::Data.tokens = []
    end
  end
end

PuppetLint.new_check(:ghostbuster_templates) do
  def check
    return if path.match(%r{^\./(:?[^/]+/){2}?templates/.+$}).nil?

    puppetdb = PuppetGhostbuster::PuppetDB.new

    template_indexes.each do |template_idx|
      title_token = template_idx[:name_token]
      title = title_token.value.split('::').map(&:capitalize).join('::')

      return if puppetdb.classes.include? title

      notify :warning, {
        :message => "Template #{title} seems unused",
        :line    => title_token.line,
        :column  => title_token.column,
      }
    end
  end
end
