require 'json'
require 'invoice_printer/version'
require 'invoice_printer/document'
require 'invoice_printer/document/entity'
require 'invoice_printer/document/item'
require 'invoice_printer/pdf_document'

# Skip warning for not specifying TTF font
Prawn::Font::AFM.hide_m17n_warning = true

# Create PDF versions of invoices or receipts using Prawn
#
# Example:
#
#   invoice = InvoicePrinter::Document.new(...)
#   InvoicePrinter.print(
#     document: invoice,
#     font: 'path-to-font-file.ttf',
#     stamp: 'stamp.jpg',
#     logo: 'logo.jpg',
#     file_name: 'invoice.pdf'
#   )
module InvoicePrinter
  # Override default English labels with a given hash
  #
  # Example:
  #
  #   InvoicePrinter.labels = {
  #     name: 'Invoice',
  #     number: '201604030001'
  #     provider: 'Provider',
  #     purchaser: 'Purchaser',
  #     issue_date: 'Issue date:',
  #     due_date: 'Due date:',
  #     item: 'Item',
  #     quantity: 'Quantity',
  #     unit: 'Unit',
  #     price_per_item: 'Price per item',
  #     amount: 'Amount'
  #   }
  #
  # You can denote the details or translations of labels by using sublabels.
  # To set a sublabel for a label, just assign it under +sublabels+ e.g.
  #
  #   InvoicePrinter.labels = {
  #     ...
  #     sublabels: { tax: 'Dan', amount: 'Celkem' }
  #   }
  def self.labels=(labels)
    PDFDocument.labels = labels
  end

  def self.labels
    PDFDocument.labels
  end

  # Print the given InvoicePrinter::Document to PDF file named +file_name+
  #
  # document - InvoicePrinter::Document object
  # labels - labels to override
  # font - font file to use
  # stamp - stamp & signature (image)
  # logo - logotype (image)
  # background - background (image)
  # file_name - output file
  def self.print(document:, file_name:, labels: {}, font: nil, stamp: nil, logo: nil, background: nil)
    PDFDocument.new(
      document: document,
      labels: labels,
      font: font,
      stamp: stamp,
      logo: logo,
      background: background
    ).print(file_name)
  end

  # Render the PDF document InvoicePrinter::Document to PDF directly
  #
  # document - InvoicePrinter::Document object
  # labels - labels to override
  # font - font file to use
  # stamp - stamp & signature (image)
  # logo - logotype (image)
  # background - background (image)
  def self.render(document:, labels: {}, font: nil, stamp: nil, logo: nil, background: nil)
    PDFDocument.new(
      document: document,
      labels: labels,
      font: font,
      stamp: stamp,
      logo: logo,
      background: background
    ).render
  end
end
