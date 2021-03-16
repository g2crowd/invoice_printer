require 'test_helper'

class InputsTest < Minitest::Test
  include InvoicePrinterHelpers

  def test_refuse_documents_of_wrong_class
    assert_raises(StandardError) do
      InvoicePrinter::PDFDocument.new(document: '')
    end

    assert_raises(StandardError) do
      InvoicePrinter.render(document: '')
    end
  end

  def test_refuse_items_of_wrong_class
    assert_raises(StandardError) do
      InvoicePrinter::Document.new(items: '')
    end
  end

  def test_missing_font_raises_an_exception
    invoice = InvoicePrinter::Document.new(**default_document_params)

    assert_raises(InvoicePrinter::PDFDocument::FontFileNotFound) do
      InvoicePrinter.render(document: invoice, font: 'missing.font')
    end
  end

  def test_missing_logo_raises_an_exception
    invoice = InvoicePrinter::Document.new(**default_document_params)

    assert_raises(InvoicePrinter::PDFDocument::LogoFileNotFound) do
      InvoicePrinter.render(document: invoice, logo: 'missing.png')
    end
  end

  def test_missing_stamp_raises_an_exception
    invoice = InvoicePrinter::Document.new(**default_document_params)

    assert_raises(InvoicePrinter::PDFDocument::StampFileNotFound) do
      InvoicePrinter.render(document: invoice, stamp: 'missing.png')
    end
  end
end
