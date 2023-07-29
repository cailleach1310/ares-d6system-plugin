module AresMUSH

  module D6System
    class PointsAwardCmd
      include CommandHandler
      
      attr_accessor :name, :points, :type, :reason

      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
        self.name = trim_arg(args.arg1)
        self.points = integer_arg(args.arg2)
        self.reason = args.arg3
        self.type = (cmd.root == 'fate') ? 'fate' : 'char'
        if (cmd.switch_is?("remove") && self.points)
          self.points = 0 - self.points
        end
      end

      def required_args
        [ self.name, self.points, self.reason ]
      end
      
      def check_points
        return nil if !self.points
        return t('d6system.invalid_point_award') if self.points == 0
        return nil
      end
      
      def check_can_award
        return nil if D6System.can_manage_points?(enactor)
        return t('dispatcher.not_allowed')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.name, client, enactor) do |model|
          if (self.type == 'char')
             points = model.xp
          elsif (self.type == 'fate')
             points = model.fate_points
          else
             return error('Invalid command')
          end
 
          if (points + self.points < 0)
            client.emit_failure  t('d6system.invalid_points_award')
            return
          end
          
          if (self.type == 'char')
             model.award_cp self.points
          elsif (self.type == 'fate')
             model.award_fate self.points
          end
          Global.logger.info "#{self.points} #{type} points awarded by #{enactor_name} to #{model.name} for reason: #{self.reason}"
          if (self.points < 0)
            client.emit_success t('d6system.points_removed', :name => model.name, :points => -self.points, :reason => self.reason, :type => self.type)
          else
            client.emit_success t('d6system.points_awarded', :name => model.name, :points => self.points, :reason => self.reason, :type => self.type)
          end
        end
      end
    end
  end
end
