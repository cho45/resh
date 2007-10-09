#!rdoc --charset utf-8 --template ~/coderepos/lang/ruby/rdoc/generators/template/html/resh/resh.rb /usr/lib/ruby/gems/1.8/gems/rake-0.7.3/{README,lib/*,doc/*}
#!rdoc --charset utf-8 --inline-source --template ~/coderepos/lang/ruby/rdoc/generators/template/html/erbdeyareyo.rb /opt/ruby1.8.5/lib/ruby/1.8/rdoc/*.rb

require "pp"
require "erb"
require "pathname"

class ::TemplateFile
	def initialize
		raise "DO NOT USE"
	end
end

module ::RDoc::Page
	FILE_INDEX   = ""
	CLASS_INDEX  = ""
	METHOD_INDEX = ""
end
$tmpl = Pathname.new(__FILE__).parent

p ::Generators::HtmlClass
class ::Generators::HtmlClass
	def write_on(f)
		return unless defined? RDoc::Page::CLASS_PAGE
		value_hash
#		template = TemplatePage.new(RDoc::Page::BODY,
#									RDoc::Page::CLASS_PAGE,
#									RDoc::Page::METHOD_LIST)
#		template.write_html_on(f, @values)
		values = @values
		f << ERB.new(File.read($tmpl+RDoc::Page::CLASS_PAGE)).result(binding)
	end
end

p ::Generators::HtmlFile
class ::Generators::HtmlFile
	def write_on(f)
		return unless defined? RDoc::Page::FILE_PAGE
		value_hash
#		template = TemplatePage.new(RDoc::Page::BODY,
#									RDoc::Page::FILE_PAGE,
#									RDoc::Page::METHOD_LIST)
#		template.write_html_on(f, @values)
		values = @values
		f << ERB.new(File.read($tmpl+RDoc::Page::FILE_PAGE)).result(binding)
	end
end

p ::Generators::HtmlMethod
class ::Generators::HtmlMethod
	def create_source_code_file(code_body)
		return unless defined? RDoc::Page::SRC_PAGE
		meth_path = @html_class.path.sub(/\.html$/, '.src')
		File.makedirs(meth_path)
		file_path = File.join(meth_path, @seq) + ".html"

		File.open(file_path, "w") do |f|
			values = {
				'title'     => CGI.escapeHTML(index_name),
				'code'      => code_body,
				'style_url' => style_url(file_path, @options.css),
				'charset'   => @options.charset
			}
			f << ERB.new(File.read($tmpl+RDoc::Page::SRC_PAGE)).result(binding)
		end
		HTMLGenerator.gen_url(path, file_path)
	end
end

p ::Generators::HTMLGenerator
class ::Generators::HTMLGenerator
	alias :orig_generate :generate
	def generate(*args)
		@options.instance_eval "@inline_source = true"
		orig_generate(*args)
	end

	# TemplatePage をつかっているのをぬきだしてきたやつ
	def write_style_sheet
		return unless defined? RDoc::Page::STYLE
		File.open(::Generators::CSS_NAME, "w") {|f|
			f << ERB.new(File.read($tmpl+RDoc::Page::STYLE)).result(binding)
		}
	end

	# Not used
	def gen_an_index(collection, title, template, filename)
		return
		res = []
		collection.sort.each do |f|
			if f.document_self
				res << { "href" => f.path, "name" => f.index_name }
			end
		end

		values = {
			"entries"    => res,
			'list_title' => CGI.escapeHTML(title),
			'index_url'  => main_url,
			'charset'    => @options.charset,
			'style_url'  => style_url('', @options.css),
		}
		begin
			File.open(filename, "w") {|f|
				f << ERB.new(File.read($tmpl+RDoc::Page.const_get(title.upcase))).result(binding)
			}
		rescue NameError
		end
	end

	def gen_main_index
		return unless defined? RDoc::Page::INDEX
		File.open("index.html", "w") do |f|
			values = {
				"initial_page" => main_url,
				'title'        => CGI.escapeHTML(@options.title),
				'charset'      => @options.charset,
				'style_url'  => style_url('', @options.css),
			}
			if @options.inline_source
				values['inline_source'] = true
			end
			f << ERB.new(File.read($tmpl+RDoc::Page::INDEX)).result(binding)
		end
	end

	def generate_xml
		values = { 
			'charset' => @options.charset,
			'files'   => gen_into(@files),
			'classes' => gen_into(@classes),
			'title'   => CGI.escapeHTML(@options.title),
		}

		# this method is defined in the template file
		write_extra_pages if defined? write_extra_pages

		if @options.op_name
			opfile = File.open(@options.op_name, "w")
		else
			opfile = $stdout
		end
		File.open(opfile, "w") {|f|
			f << ERB.new(File.read($tmpl+RDoc::Page::ONE_PAGE)).result(binding)
		}
	end
end

module RDoc::Page
	INDEX      = "index.rhtml"
	CLASS_PAGE = "class.rhtml"
	FILE_PAGE  = "file.rhtml"
#	SRC_PAGE   = "src.rhtml"
	STYLE      = "style.css"
#	ONE_PAGE   = "one_page.rhtml"
	

end
