module FuzzyTools
  module Helpers
    extend self

    def term_counts(enumerator)
      {}.tap do |counts|
        enumerator.each do |e|
          counts[e] ||= 0
          counts[e]  += 1
        end
      end
    end

    def bigrams(str)
      ngrams(str, 2)
    end

    def trigrams(str)
      ngrams(str, 3)
    end
    
    def tetragrams(str)
      ngrams(str, 4)
    end
  
    def ngrams(str, n)
      ends   = "_" * (n - 1)
      str    = "#{ends}#{str}#{ends}"
    
      (0..str.length - n).map { |i| str[i,n] }
    end

    if RUBY_DESCRIPTION !~ /^ruby/ # rbx, jruby

      SOUNDEX_LETTERS_TO_CODES = {
        'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3, 'E' => 0, 'F' => 1,
        'G' => 2, 'H' => 0, 'I' => 0, 'J' => 2, 'K' => 2,
        'L' => 4, 'M' => 5, 'N' => 5, 'O' => 0, 'P' => 1,
        'Q' => 2, 'R' => 6, 'S' => 2, 'T' => 3, 'U' => 0,
        'V' => 1, 'W' => 0, 'X' => 2, 'Y' => 0, 'Z' => 2
      }

      # Ruby port of the C below
      def soundex(str)
        soundex = "Z000"
        chars = str.upcase.chars.to_a
        first_letter = chars.shift until (last_numeral = first_letter && SOUNDEX_LETTERS_TO_CODES[first_letter]) || chars.size == 0

        return soundex unless last_numeral

        soundex[0] = first_letter

        i = 1
        while i < 4 && chars.size > 0
          char = chars.shift
          next unless numeral = SOUNDEX_LETTERS_TO_CODES[char]
          if numeral != last_numeral
            last_numeral = numeral
            if numeral != 0
              soundex[i] = numeral.to_s
              i += 1
            end
          end
        end

        soundex
      end

    else # MRI

      require 'inline'

      # http://en.literateprograms.org/Soundex_(C)
      inline(:C) do |builder|
        builder.include '<ctype.h>'
        builder.c_raw <<-EOC
          static VALUE soundex(int argc, VALUE *argv, VALUE self) {
            VALUE  ruby_str = argv[0];
            char * in;

            static  int code[] =
               {  0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2 };
               /* a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z */
            static   char key[5];
            register char ch;
            register int last;
            register int count;

            Check_Type(ruby_str, T_STRING);

            in = StringValueCStr(ruby_str);

            /* Set up default key, complete with trailing '0's */
            strcpy(key, "Z000");

            /* Advance to the first letter.  If none present,
               return default key */
            while (*in != '\\0'  &&  !isalpha(*in))
               ++in;
            if (*in == '\\0')
               return rb_str_new2(key);

            /* Pull out the first letter, uppercase it, and
               set up for main loop */
            key[0] = toupper(*in);
            last = code[key[0] - 'A'];
            ++in;

            /* Scan rest of string, stop at end of string or
               when the key is full */
            for (count = 1;  count < 4  &&  *in != '\\0';  ++in) {
               /* If non-alpha, ignore the character altogether */
               if (isalpha(*in)) {
                  ch = tolower(*in);
                  /* Fold together adjacent letters sharing the same code */
                  if (last != code[ch - 'a']) {
                     last = code[ch - 'a'];
                     /* Ignore code==0 letters except as separators */
                     if (last != 0)
                        key[count++] = '0' + last;
                  }
               }
            }

            return rb_str_new2(key);
          }
        EOC
      end

    end

  end
end