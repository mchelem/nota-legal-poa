#!/usr/bin/env ruby
# coding: utf-8

require 'ostruct'
require 'yaml'
require 'json'

require 'watir'

require_relative 'notalegal'
require_relative 'taxes'

# A client to Porto Alegre's invoice generation system
class InvoiceWebApplicationClient
  include NotaLegal
  include PresumedProfit
  # rubocop:disable Metrics/AbcSize

  def construct
    @browser = nil
  end

  def generate_invoice(config)
    @browser = open_browser config.browser
    login config.login
    start_invoice_for_current_date
    fill_company_info config.company
    fill_job_description config.job
    fill_income_and_taxes config.job
    complete_invoice_generation
  end

  def open_browser(browser)
    # Must use firefox <= 51 or (52esr) because the Java plugin is required
    Selenium::WebDriver::Firefox.path = browser.path
    options = Selenium::WebDriver::Firefox::Options.new

    # Setting profile skips the annoying old same questions
    options.profile = browser.profile || :default
    @browser = Watir::Browser.new(:firefox, options: options)
  end

  def login(login)
    @browser.goto(LOGIN_URL)

    @browser.text_field(id: id(:username)).set(login.username)
    @browser.text_field(id: id(:password)).set(login.password)

    @browser.forms.first.submit
  end

  def start_invoice_for_current_date
    @browser.image(id: id(:generate_invoice)).wait_until_present
    @browser.execute_script(script(:generate_invoice))
    fill_current_date
    @browser.input(id: id(:confirm_invoice)).click
  end

  def fill_current_date
    @browser.link(id: id(:fill_date_today)).click
    date = @browser.input(id: id(:date))
    Watir::Wait.until { date.value != '' }
  end

  def fill_company_info(company)
    @browser.radio(id: id(:company_type_cnpj)).wait_until_present
    @browser.radio(id: id(:company_type_cnpj)).set

    @browser.text_field(id: id(:cnpj)).set(company.cnpj)
    @browser.text_field(id: id(:company_name)).set(company.name)

    @browser.text_field(id: id(:zip_code)).set(company.zip_code)
    @browser.text_field(id: id(:street)).set(company.street)
    @browser.text_field(id: id(:street_number)).set(company.street_number)
    @browser.text_field(id: id(:neighborhood)).set(company.neighborhood)

    fill_company_city company
    reset_company_id company
  end

  def reset_company_id(company)
    # HACK: setting these fields again because they get erased
    # Setting them only here doesn't work as other fields will go missing
    @browser.text_field(id: id(:cnpj)).set(company.cnpj)
    @browser.text_field(id: id(:company_name)).set(company.name)
  end

  def fill_company_city(company)
    @browser.input(id: id(:city_search_modal)).click

    @browser.text_field(id: id(:city_search)).wait_until_present
    @browser.text_field(id: id(:city_search)).set(company.city)
    @browser.select_list(id: id(:state_search)).select(company.state)
    @browser.input(id: id(:city_search_submit)).click
    @browser.link(id: id(:confirm_city)).click
  end

  def fill_job_description(job)
    @browser.execute_script(script(:service_description_tab))

    @browser.textarea(id: id(:service_description)).wait_until_present
    @browser.textarea(id: id(:service_description)).set(job.description)
    @browser.select_list(id: id(:activity_code)).select(job.cnae_code)
  end

  def fill_income_and_taxes(job)
    @browser.execute_script(script(:income_tab))

    @browser.text_field(id: id(:income)).wait_until_present
    @browser.text_field(id: id(:income)).set(currency(job.income))

    fill_taxes job.income
  end

  def complete_invoice_generation
    @browser.input(id: id(:emit_invoice)).click
  end

  private

  def fill_taxes(income)
    @browser.text_field(id: id(:irpj)).set(currency(irpj(income)))
    @browser.text_field(id: id(:pis)).set(currency(pis(income)))
    @browser.text_field(id: id(:cofins)).set(currency(cofins(income)))
    @browser.text_field(id: id(:csll)).set(currency(csll(income)))
  end

  def currency(value)
    format('%.2f', value)
  end
end

def load_config(filename)
  config = YAML.load_file(filename)
  # Hackish way to turn haml into an object
  JSON.parse(config.to_json, object_class: OpenStruct)
end

if ARGV.length != 1
  puts 'Usage: ./invoice.rb config.yaml'
else
  config = load_config ARGV[0]
  client = InvoiceWebApplicationClient.new
  client.generate_invoice(config)
end
