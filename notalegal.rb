# coding: utf-8

# Element ids and URLs of the nota legal website
module NotaLegal
  # rubocop:disable LineLength
  ELEMENT_ID = {
    username: 'username',
    password: 'password',
    generate_invoice: 'geracao',
    fill_date_today: 'MesReferenciaModalPanelSubview:formMesReferencia:j_id172',
    confirm_invoice: 'MesReferenciaModalPanelSubview:formMesReferencia:bt_confirmar_comp_subs',
    company_type_cnpj: 'form:tipoPessoa:1',
    cnpj: 'form:numDocumento',
    company_name: 'form:dnomeRazaoSocial',
    zip_code: 'form:cep',
    street: 'form:logradouro',
    street_number: 'form:numero',
    neighborhood: 'form:bairro',
    city_search_modal: 'form:j_id185',
    city_search: 'ConsultaMunicipioModalPanelSubview:formPanel:nomeMunicipioModalPanel',
    state_search: 'ConsultaMunicipioModalPanelSubview:formPanel:estadoMunicipio',
    city_search_submit: 'ConsultaMunicipioModalPanelSubview:formPanel:bt_consultar_municipio_tomador',
    confirm_city: 'ConsultaMunicipioModalPanelSubview:formPanel:listaMunicipios:0:j_id609',
    service_description: 'form:descriminacaoServico',
    activity_code: 'form:codigoCnae',
    income: 'form:valorServicos',
    irpj: 'form:valorIR',
    pis: 'form:valorPis',
    cofins: 'form:valorCofins',
    csll: 'form:valorCSLL',
    emit_invoice: 'form:bt_emitir_NFS-e'
  }.freeze
  # rubocop:enable LineLength

  URL = 'https://nfe.portoalegre.rs.gov.br'.freeze
  LOGIN_URL = URL + '/nfse/pages/security/login.jsf'

  private

  def id(name)
    ELEMENT_ID[name]
  end
end
