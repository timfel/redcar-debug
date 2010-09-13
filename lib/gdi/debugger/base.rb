class GDI::Debugger::Base < GDI::Debugger
  abstract!
  file_linker GDI::Debugger::Files::DefaultLinker
  display_name :name
  before_output :process_links

  def process_links(text)
    text = @file_linker.find_links(text).inject(text) do |txt, l|
      txt.sub(l[:match], <<-HTML)
      <span class="file_link" data-file="#{l[:file]}" data-line="#{l[:line]}">
      #{l[:match]}
      </span>
      HTML
    end
  end
end
