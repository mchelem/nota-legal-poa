# coding: utf-8

# Taxes collected by the payer accordint to presumed profit regimen
# http://www.empreendimentocontabil.com/informativos/lucro-presumido
module PresumedProfit
  def pis(income)
    income * (0.65 / 100)
  end

  def irpj(income)
    income * (1.5 / 100)
  end

  def cofins(income)
    income * (3.0 / 100)
  end

  def csll(income)
    income * (1.0 / 100)
  end
end
