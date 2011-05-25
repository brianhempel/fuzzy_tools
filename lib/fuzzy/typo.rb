module Fuzzy
  class Typo
  
    class << self
      attr_accessor :gap_score, :single_gap_score, :match_score, :mismatch_score, :switched_score
    end
    
    def self.ensure_scores
      @gap_score        ||= -1
      @single_gap_score ||= 1.4928745
      @match_score      ||= 5.0345351 # tie breakers decimal places!
      @mismatch_score   ||= 1.0293847
      @switched_score   ||= 3.2345563
    end
  
    def self.distance(a, b)
      a_arr = a.split(//)
      b_arr = b.split(//)
      
      align(a_arr, b_arr)
    end
    
    def self.align(a_arr, b_arr)
      #     a _ w o r d
      #   0 0 0 0 0 0 0
      # b 0
      # a 0
      # _ 0
      # w 0        # diagonal is match/mismatch
      # r 0        # horizontal or veritcal is gap
      # o 0
      # d 0
      
      ensure_scores
      
      scores    = [ [0.0]*(a_arr.size+1) ] * (b_arr.size+1)
      gap_sizes = [ [ 0 ]*(a_arr.size+1) ] * (b_arr.size+1)
            
      # initialize top row
      scores[0].each_index do |i|
        next if i == 0
        
        scores[0][i]    = scores[0][i-1] + ( gap_sizes[0][i-1] > 0 ? gap_score : single_gap_score )            
        gap_sizes[0][i] = gap_sizes[0][i-1] + 1
      end

      # initialize left col
      scores.each_index do |j|
        next if j == 0
        
        scores[j][0]    = scores[j-1][0] + ( gap_sizes[j-1][0] > 0 ? gap_score : single_gap_score )
        gap_sizes[j][0] = gap_sizes[j-1][0] + 1
      end
      
      scores.each_index do |j|
        next if j == 0
        
        scores[j].each_index do |i|
          next if i == 0
          
          vertical_score   = scores[j-1][i]   + ( gap_sizes[j-1][i] > 0    ?   gap_score : single_gap_score )
          horizontal_score = scores[j][i-1]   + ( gap_sizes[j][i-1] > 0    ?   gap_score : single_gap_score )
          diagonal_score   = scores[j-1][i-1] + begin
            if a_arr[i-1] == b_arr[j-1]
              match_score
            elsif j > 1 && i > 1 && a_arr[i-2] == b_arr[j-1] && a_arr[i-1] == b_arr[j-2]
              switched_score
            else
              mismatch_score
            end
          end
          
          if vertical_score > horizontal_score && vertical_score > diagonal_score
            # move down
            scores[j][i]    = vertical_score
            gap_sizes[j][i] = gap_sizes[j-1][i] + 1
          elsif horizontal_score > vertical_score && horizontal_score > diagonal_score
            # move right
            scores[j][i]    = horizontal_score            
            gap_sizes[j][i] = gap_sizes[j][i-1] + 1
          else
            # move diagonal
            scores[j][i]    = diagonal_score
          end
          
          # max, max_j, max_i = [scores[j][i], j, i] if scores[j][i] >= max
        end
        
        # puts scores[j][1..-1].inspect
      end
      
      scores.last.last
    end
    
  end
end