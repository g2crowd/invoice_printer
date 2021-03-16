require 'prawn'
require 'prawn/table'

module InvoicePrinter
  # Prawn PDF representation of InvoicePrinter::Document
  #
  # Example:
  #
  #   invoice = InvoicePrinter::Document.new(...)
  #   invoice_pdf = InvoicePrinter::PDFDocument.new(
  #     document: invoice,
  #     labels: {},
  #     font: 'font.ttf',
  #     stamp: 'stamp.jpg',
  #     logo: 'example.jpg'
  #   )
  class PDFDocument
    FontFileNotFound = Class.new(StandardError)
    LogoFileNotFound = Class.new(StandardError)
    StampFileNotFound = Class.new(StandardError)
    InvalidInput = Class.new(StandardError)

    attr_reader :invoice, :labels, :file_name, :font, :stamp, :logo

    DEFAULT_LABELS = {
      name: 'Invoice',
      provider: 'Provider',
      purchaser: 'Purchaser',
      tax_id: 'Identification number',
      tax_id2: 'Identification number',
      issue_date: 'Issue Date',
      due_date: 'Due Date',
      charge_date: 'Charge Date',
      item: 'Item',
      variable: '',
      quantity: 'Quantity',
      unit: 'Unit',
      price_per_item: 'Price per item',
      tax: 'Tax',
      amount: 'Amount',
      subtotal: 'Subtotal',
      total: 'Total',
      sublabels: {}
    }.freeze

    def self.labels
      @@labels ||= DEFAULT_LABELS
    end

    def self.labels=(labels)
      @@labels = DEFAULT_LABELS.merge(labels)
    end

    def initialize(document: Document.new, labels: {}, font: nil, stamp: nil, logo: nil, background: nil)
      @document = document
      @labels = merge_custom_labels(labels)
      @font = font
      @pdf = Prawn::Document.new(background: background, page_size: 'LETTER')

      raise InvalidInput, 'document is not a type of InvoicePrinter::Document' \
        unless @document.is_a?(InvoicePrinter::Document)

      if used? logo
        raise LogoFileNotFound, "Logotype file not found at #{logo}" unless File.exist?(logo)

        @logo = logo
      end

      if used? stamp
        raise StampFileNotFound, "Stamp file not found at #{stamp}" unless File.exist?(stamp)

        @stamp = stamp
      end

      use_font(@font) if used? @font

      build_pdf
    end

    # Create PDF file named +file_name+
    def print(file_name = 'invoice.pdf')
      @pdf.render_file file_name
    end

    # Directly render the PDF
    def render
      @pdf.render
    end

    private

    def use_font(font)
      if File.exist?(font)
        set_font_from_path(font)
      else
        set_builtin_font(font)
      end
    end

    def set_builtin_font(font)
      require 'invoice_printer/fonts'

      @pdf.font_families.update(font.to_s => InvoicePrinter::Fonts.paths_for(font))
      @pdf.font(font)

    rescue StandardError
      raise FontFileNotFound, "Font file not found for #{font}"
    end

    # Add font family in Prawn for a given +font+ file
    def set_font_from_path(font)
      font_name = Pathname.new(font).basename
      @pdf.font_families.update(
        font_name.to_s => {
          normal: font,
          italic: font,
          bold: font,
          bold_italic: font
        }
      )
      @pdf.font(font_name)
    end

    # Build the PDF version of the document (@pdf)
    def build_pdf
      @push_down = 0
      @push_items_table = 0
      @pdf.fill_color '000000'
      @pdf.stroke_color 'aaaaaa'
      build_header
      build_entity_box label: :provider
      build_entity_box label: :purchaser, offset: 274
      build_info_box
      build_items
      build_total
      build_stamp
      build_logo
      build_note
      build_footer
    end

    # Build the document name and number at the top:
    #
    #   NAME                      NO. 901905374583579
    #   Sublabel name
    def build_header
      @pdf.text_box(
        @labels[:name],
        size: 20,
        align: :left,
        at: [0, 720 - @push_down],
        width: 300
      )

      if used? @labels[:sublabels][:name]
        @pdf.text_box(
          @labels[:sublabels][:name],
          size: 12,
          at: [0, 720 - @push_down - 22],
          width: 300,
          align: :left
        )
      end

      unless @document.status.empty?
        @pdf.fill_color.tap do |original|
          @pdf.fill_color 'ff0000'
          @pdf.text_box(
            @document.status,
            size: 20,
            at: [220, 710 - @push_down],
            rotate: 20
          )
          @pdf.fill_color original
        end
      end

      @pdf.text_box(
        @document.number,
        size: 20,
        at: [240, 720 - @push_down],
        width: 300,
        align: :right
      )

      @pdf.move_down(250)
      @pdf.move_down(12) if used? @labels[:sublabels][:name]
    end

    def build_entity_box(label:, offset: 0)
      entity = @document.public_send label

      @pdf.text_box(
        entity.name,
        size: 15,
        at: [10 + offset, 640 - @push_down],
        width: 240
      )

      @pdf.text_box(
        @labels[label],
        size: 11,
        at: [10 + offset, 660 - @push_down],
        width: 240
      )

      unless entity.lines.empty?
        lines = entity.lines.split("\n")
        line_y = 618
        lines.each_with_index do |line, index|
          next if index > 5

          @pdf.text_box(
            line.to_s,
            size: 10,
            at: [10 + offset, (line_y - index * 15) - @push_down],
            width: 240
          )
        end
      end

      @pdf.stroke_rounded_rectangle([offset, 670 - @push_down], 266, 150, 6)
    end

    # Build the following info box:
    #
    #    --------------------------------
    #   | Issue date:          03/03/2016|
    #   | Issue date sublabel            |
    #   | Due date:            03/03/2016|
    #   | Due date sublabel              |
    #    --------------------------------
    #
    def build_info_box
      dates = 0

      %i[issue_date due_date charge_date].each do |date|
        value = @document.public_send(date)
        next if value.empty?

        position = 498 - (dates * 20)
        dates += 1

        @pdf.text_box(
          @labels[date],
          size: 11,
          at: [10, position - @push_down],
          width: 240
        )
        @pdf.text_box(
          value,
          size: 11,
          at: [110, position - @push_down],
          width: 146,
          align: :right
        )
      end

      @push_items_table += 45 + (dates - 1) * 15 if dates.positive?
    end

    # Build the following table for document items:
    #
    #   =================================================================
    #   |Item |  Quantity|  Unit|  Price per item|  Tax|  Total per item|
    #   |-----|----------|------|----------------|-----|----------------|
    #   |x    |         2|    hr|              $2|   $1|              $4|
    #   =================================================================
    #
    # variable (2nd position) field can be added as well if necessary.
    # variable does not come with any default label.
    # If a specific column miss data, it's omitted.
    #
    # Using sublabels one can change the table to look as:
    #
    #   =================================================================
    #   |Item |  Quantity|  Unit|  Price per item|  Tax|  Total per item|
    #   |it.  |      nom.|   un.|            ppi.|   t.|            tpi.|
    #   |-----|----------|------|----------------|-----|----------------|
    #   |x    |         2|    hr|              $2|   $1|              $4|
    #   =================================================================
    def build_items
      @pdf.move_down(@push_items_table + @push_down)

      items_params = determine_items_structure
      items = build_items_data(items_params)
      headers = build_items_header(items_params)
      data = items.prepend(headers)

      options = {
        header: true,
        row_colors: [nil, 'ededed'],
        width: 540,
        cell_style: {
          borders: []
        }
      }

      unless items.empty?
        @pdf.font_size(10) do
          @pdf.table(data, options) do
            row(0).background_color = 'e3e3e3'
            row(0).border_color = 'aaaaaa'
            row(0).borders = [:bottom]
            row(items.size - 1).borders = [:bottom]
            row(items.size - 1).border_color = 'd9d9d9'
          end
        end
      end
    end

    # Determine sections of the items table to show based on provided data
    def determine_items_structure
      items_params = {}
      @document.items.each do |item|
        items_params[:names] = true unless item.name.empty?
        items_params[:variables] = true unless item.variable.empty?
        items_params[:quantities] = true unless item.quantity.empty?
        items_params[:units] = true unless item.unit.empty?
        items_params[:prices] = true unless item.price.empty?
        items_params[:taxes] = true unless item.tax.empty?
        items_params[:amounts] = true unless item.amount.empty?
      end
      items_params
    end

    # Include only items params with provided data
    def build_items_data(items_params)
      @document.items.map do |item|
        line = []
        line << { content: item.name, borders: [:bottom], align: :left } if items_params[:names]
        line << { content: item.variable, align: :right } if items_params[:variables]
        line << { content: item.quantity, align: :right } if items_params[:quantities]
        line << { content: item.unit, align: :right } if items_params[:units]
        line << { content: item.price, align: :right } if items_params[:prices]
        line << { content: item.tax, align: :right } if items_params[:taxes]
        line << { content: item.amount, align: :right } if items_params[:amounts]
        line
      end
    end

    # Include only relevant headers
    def build_items_header(items_params)
      headers = []
      headers << { content: label_with_sublabel(:item), align: :left } if items_params[:names]
      headers << { content: label_with_sublabel(:variable), align: :right } if items_params[:variables]
      headers << { content: label_with_sublabel(:quantity), align: :right } if items_params[:quantities]
      headers << { content: label_with_sublabel(:unit), align: :right } if items_params[:units]
      headers << { content: label_with_sublabel(:price_per_item), align: :right } if items_params[:prices]
      headers << { content: label_with_sublabel(:tax), align: :right } if items_params[:taxes]
      headers << { content: label_with_sublabel(:amount), align: :right } if items_params[:amounts]
      headers
    end

    # This merge a label with its sublabel on a new line
    def label_with_sublabel(symbol)
      value = @labels[symbol]
      value += "\n#{@labels[:sublabels][symbol]}" if used? @labels[:sublabels][symbol]
      value
    end

    # Build the following summary:
    #
    #   Subtotal: 175
    #        Tax: 5
    #      Tax 2: 10
    #      Tax 3: 20
    #
    #      Total: $ 200
    #
    # The first part is implemented as a table without borders.
    def build_total
      @pdf.move_down(25)

      items = []
      items << [{ content: "#{@labels[:subtotal]}:#{build_sublabel_for_total_table(:subtotal)}", align: :right }, @document.subtotal] \
        unless @document.subtotal.empty?
      items << [{ content: "#{@labels[:tax]}:#{build_sublabel_for_total_table(:tax)}", align: :right }, @document.tax] \
        unless @document.tax.empty?

      width = [
        "#{@labels[:subtotal]}#{@document.subtotal}".size,
        "#{@labels[:tax]}#{@document.tax}".size
      ].max * 8

      options = {
        cell_style: {
          borders: []
        }
      }

      @pdf.span(width, position: :right) do
        @pdf.table(items, options) unless items.empty?
      end

      @pdf.move_down(15)

      return if @document.total.empty?

      @pdf.text(
        "#{@labels[:total]}:   #{@document.total}",
        size: 16,
        align: :right,
        style: :bold
      )

      @pdf.move_down(5)

      if used? @labels[:sublabels][:total]
        @pdf.text(
          "#{@labels[:sublabels][:total]}:   #{@document.total}",
          size: 12,
          align: :right
        )
      end
    end

    # Return sublabel on a new line or empty string
    def build_sublabel_for_total_table(sublabel)
      if used? @labels[:sublabels][sublabel]
        "\n#{@labels[:sublabels][sublabel]}:"
      else
        ''
      end
    end

    # Insert a logotype at the left bottom of the document
    #
    # If a note is present, position it on top of it.
    def build_logo
      if @logo && !@logo.empty?
        bottom = @document.note.empty? ? 75 : (75 + note_height)
        @pdf.image(@logo, at: [0, bottom], fit: [200, 50])
      end
    end

    # Insert a stamp (with signature) after the total table
    def build_stamp
      if @stamp && !@stamp.empty?
        @pdf.move_down(15)
        @pdf.image(@stamp, position: :right)
      end
    end

    # Note at the end
    def build_note
      @pdf.text_box(
        @document.note.to_s,
        size: 10,
        at: [0, note_height],
        width: 450,
        align: :left
      )
    end

    def note_height
      @note_height ||=
        begin
          num_of_lines = @document.note.lines.count
          (num_of_lines * 11)
        end
    end

    # Include page numbers if we got more than one page
    def build_footer
      return if @pdf.page_count == 1

      @pdf.number_pages(
        '<page> / <total>',
        start_count_at: 1,
        at: [@pdf.bounds.right - 50, 0],
        align: :right,
        size: 12
      )
    end

    def used?(element)
      element && !element.empty?
    end

    def merge_custom_labels(labels = {})
      custom_labels = if labels
                        hash_keys_to_symbols(labels)
                      else
                        {}
                      end

      PDFDocument.labels.merge(custom_labels)
    end

    def hash_keys_to_symbols(value)
      return value unless value.is_a? Hash

      value.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = hash_keys_to_symbols(v)
      end
    end
  end
end
