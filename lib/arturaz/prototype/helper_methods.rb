module Arturaz
  module Prototype
    module HelperMethods
      def link_to_remote_href(name, options = {}, html_options = {})
        html_options[:href] ||= url_for(options[:url]) if options[:url]
        link_to_remote(name, options, html_options)
      end

      def indicator(model, attr, mesage="Kraunama...")
        hidden_div("#{model}_#{attr}", progress_meter(message))
      end
      
      def progress_meter(message="Kraunama...")
        image_tag("progress.gif", :alt => message) + " #{message}"
      end
      
      def form_remote_tag(options={})
        options[:ajax_errors] ||= "ajax_errors"
        if options[:ajax_errors]
          options[:loading] ||= ""
          options[:loading] += ";clear_ajax_errors(event.target, " +
            "'#{options[:ajax_errors]}');"
        end
        
        options[:url] ||= {}    
        parse_extra_prototype_options(options)
        
        super(options)
      end
      
      def observe_field(field_id, options = {})
        super(field_id, parse_extra_prototype_options(options))
      end
      
      def link_to_remote(name, options = {}, html_options = {})
        super(name, parse_extra_prototype_options(options), html_options)
      end
      
      def parse_extra_prototype_options(options)
        unless options[:progress].blank?
          options[:indicator], options[:progress] = options[:progress], nil
        end
        
        if options[:indicator]      
          options[:loading] ||= ""
          options[:loading] += ";Element.show('#{options[:indicator]}');"
          
          options[:complete] ||= ""
          options[:complete] += ";Element.hide('#{options[:indicator]}');"
        end
        
        options
      end
      
      def css_hidden
        'display: none'
      end
      
      def hidden_div(id, message_or_options_with_block=nil, options={},
      &block)
        if block.nil?
          message = message_or_options_with_block
        else
          message = capture(&block)
          options = message_or_options_with_block || {}
        end
        
        html = content_tag(
          :div, 
          message, 
          options.merge(:id => id, :style => css_hidden)
        )
        
        if block.nil?
          html
        else      
          concat(html, block.binding)
        end
      end
    
      def ajax_flash(page, message, htmlid='ajax_flash')
        page.replace_html(htmlid, message) +
        page.show(htmlid) +
        page.visual_effect(:highlight, htmlid)    
      end      
          
      def js_element_show_hide(id)
        "{ $('#{id}').show() } else { $('#{id}').hide() }"
      end
      
      def js_element_hide_show(id)
        "{ $('#{id}').hide() } else { $('#{id}').show() }"
      end
  
      def visual_effect_html(name, element_id = false, js_options = {})
        javascript_start_tag +
        visual_effect(name, element_id, js_options) +
        javascript_end_tag
      end
        
      def periodically_execute(function, frequency=0.5)
        javascript_tag(
          "new PeriodicalExecuter(function(){#{function}},#{frequency});"
        )
      end
    end
  end
end
