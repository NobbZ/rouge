# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    # load_lexer 'haskell.rb'

    class Idris < RegexLexer
      title "Idris"
      desc "A Language with Dependent Types (idris-lang.org)"

      tag 'idris'
      aliases 'idr'
      filenames '*.idr'

      module_name = /[A-Z][[:alnum:]]*(\.[A-Z][[:alnum:]]*)*/

      reserved = %w(
        infix[lr]?
      )

      ws = "[ \\n\\t\\v]"

      state :ws do
        rule /#{ws}/, Text::Whitespace
      end

      state :numbers do
        rule /[[:digit:]]+/, Num::Integer 
      end

      state :module_dec do
        mixin :ws

        rule module_name, Name::Namespace, :pop!
      end

      state :import do
        mixin :ws

        rule module_name, Name::Namespace, :pop!
      end

      state :preproc do
        rule /$/, Comment::Preproc, :pop! # Leave gracefully on unknown pragmas
        rule /access#{ws}+((public#{ws})?export|private)$/, Comment::Preproc, :pop!
        rule /default#{ws}+(total|implicit|partial|covering)$/, Comment::Preproc, :pop!
        rule /elim/, Comment::Preproc, :pop!
      end

      state :data_decl do
        mixin :ws

        rule /\bwhere\b/, Keyword::Declaration, :pop!
        rule /(#{module_name}.)?[A-Z][A-Za-z0-9]*/, Name::Class
        rule %r(:|->), Operator
        rule %r(\(), Punctuation, :implicit
      end

      state :implicit do
        mixin :ws
        mixin :numbers

        rule /\)/, Punctuation, :pop!
        rule /[A-Z][A-Za-z0-9]*/, Name::Class
        rule /[a-z][A-Za-z0-9]*/, Name::Variable
        rule /:/, Operator
      end

      state :root do
        mixin :ws
        mixin :numbers

        rule /--.*$/, Comment::Single
        rule /\|\|\|.*$/, Comment::Doc

        rule /\bmodule\b/, Keyword::Reserved, :module_dec
        rule /\bimport#{ws}*(public)?\b/, Keyword::Reserved, :import
        rule /%/, Comment::Preproc, :preproc

        rule /\bdata\b/, Keyword::Declaration, :data_decl

        rule /\b(?:#{reserved.join('|')})\b/, Keyword::Reserved

        rule /[:!#\$\%&*+.\\\/<=>?@^\|~-]+/, Operator
      end
    end
  end
end