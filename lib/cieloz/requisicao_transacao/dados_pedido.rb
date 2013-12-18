class Cieloz::RequisicaoTransacao
  class DadosPedido
    include Cieloz::Helpers

    IDIOMAS = [ "PT", "EN", "ES" ] # portugues, ingles, espanhol

    hattr_writer  :dados_avs
    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor
    attr_reader   :dados_avs

    validates :numero, :valor, :moeda, :data_hora, presence: true

    validates :numero, length: { maximum: 20 }

    validates :valor, length: { maximum: 12 }
    validates :valor, numericality: { only_integer: true }, unless: "@valor.blank?"

    validates :descricao, length: { maximum: 1024 }
    validates :idioma, inclusion: { in: IDIOMAS }
    validates :soft_descriptor, length: { maximum: 13 }

    validate :nested_validations

    def self.map(source, opts={})
      mappings = attrs_from source, opts, :numero, :valor,
        :descricao, :data_hora, :moeda, :idioma, :soft_descriptor,
        :dados_avs

      num, val, desc, time, cur, lang, soft, avs = mappings
      val = (val * 100).round unless val.nil? or val.integer?

      time  ||= Time.now
      cur   ||= Cieloz::Configuracao.moeda
      lang  ||= Cieloz::Configuracao.idioma
      soft  ||= Cieloz::Configuracao.soft_descriptor

      new source: source, opts: opts,
        data_hora: time, numero: num, valor: val, moeda: cur,
        idioma: lang, descricao: desc, soft_descriptor: soft,
        dados_avs: avs
    end

    def attributes
      {
        numero:           @numero,
        valor:            @valor,
        moeda:            @moeda,
        data_hora:        @data_hora.strftime("%Y-%m-%dT%H:%M:%S"),
        descricao:        @descricao,
        idioma:           @idioma,
        soft_descriptor:  @soft_descriptor,
        dados_avs:        @dados_avs
      }
    end

    def build_xml builder
      builder.tag! 'dados-pedido' do
          attributes.each do |attr, value|
            next if value.nil?

            if attr == :dados_avs
              value.build_xml builder
            else
              builder.tag! dasherize_attr(attr), value
            end
          end
        end
    end

    def nested_validations
      if not @dados_avs.nil? and not @dados_avs.valid?
        errors.add :dados_avs, @dados_avs.errors
      end
    end

  end

end
