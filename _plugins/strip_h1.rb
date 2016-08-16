module Jekyll
  module Strip_H1
    def strip_h1(input, reg_str)
      re = Regexp.new reg_str
      input.gsub re, ""
    end
  end
end

Liquid::Template.register_filter(Jekyll::Strip_H1)
