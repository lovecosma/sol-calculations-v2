# frozen_string_literal: true

module NameNormalizable
  extend ActiveSupport::Concern

  PREFIXES = /\A(Mr|Mrs|Ms|Miss|Dr|Rev|Prof|Sir|Lady|Lord)\.?\s+/i
  SUFFIXES = /[\s,]+(Jr|Sr|II|III|IV|V|VI|VII|VIII|IX|X|PhD|MD|Esq|DDS|DVM|JD)\.?\z/i

  def strip_affixes(name)
    name.gsub(PREFIXES, '').gsub(SUFFIXES, '').strip
  end
end
