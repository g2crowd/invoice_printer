require 'json'
require 'pdf/inspector'
require 'rack/test'

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'invoice_printer'
require 'test_ext'
require 'minitest/autorun'

# Test helpers
module InvoicePrinterHelpers
  def default_document_params
    {
      number: '198900000001',
      provider_name: 'Business s.r.o.',
      provider_lines: default_provider_address,
      purchaser_name: 'Adam',
      purchaser_lines: default_purchaser_address,
      issue_date: '19/03/3939',
      due_date: '19/03/3939',
      subtotal: '175',
      tax: '5',
      total: '$ 200',
      items: [
        InvoicePrinter::Document::Item.new(
          **default_document_item_params
        )
      ]
    }
  end

  def default_provider_address
    <<~ADDRESS
      Rolnicka 1
      747 05  Opava
      Katerinky
      Czech Republic
    ADDRESS
  end

  def default_purchaser_address
    <<~ADDRESS
      Ostravska 1
      747 70  Opava
    ADDRESS
  end

  def default_document_item_params
    {
      name: 'Web consultation',
      quantity: '2',
      unit: 'hours',
      price: '$ 25',
      tax: '$ 1',
      amount: '$ 100'
    }
  end
end
