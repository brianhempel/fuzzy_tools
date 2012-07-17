require 'inline'

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

    # http://en.literateprograms.org/Soundex_(C)
    inline(:C) do |builder|
      builder.include '<ctype.h>'
      builder.c_raw <<-EOC
        static VALUE soundex(int argc, VALUE *argv, VALUE self) {
          VALUE ruby_str = argv[0];

          Check_Type(ruby_str, T_STRING);

          char * in = STR2CSTR(ruby_str);

          static  int code[] =
             {  0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2 };
             /* a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z */
          static   char key[5];
          register char ch;
          register int last;
          register int count;

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