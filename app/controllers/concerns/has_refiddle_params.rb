module HasRefiddleParams
  private

    def refiddle_params
      params.fetch(:refiddle,{}).permit(
        :title,:description,:share,:locked,:corpus_deliminator,:tags,:regex,:corpus_text,:replace_text, :flavor,
        pattern_attributes: [:regex,:corpus_text,:replace_text]
        )
    end
end