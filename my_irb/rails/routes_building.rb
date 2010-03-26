module MyIrb::Rails
  class RoutesBuilding
    # Can't just replace STDOUT http://rubyforge.org/tracker/index.php?func=detail&aid=5217&group_id=426&atid=1698
    module IoInterceptor
      def intercept
        begin
          @intercept = true
          @intercepted = ""
          yield
        ensure
          @intercept = false
        end
        @intercepted
      end

      def write(str)
        if @intercept
          @intercepted << str
          str.size
        else
          super
        end
      end
    end

    # Always up to date routes in Rails.root + "routes.txt"
    def self.build
      last_mtime = nil

      loop do
        sleep 1

        begin
          cur_mtime = File.stat(Rails.root + "config/routes.rb").mtime

          if last_mtime == nil || cur_mtime != last_mtime
            # puts "Rebuilding routes at #{ Time.now }"

            File.open(Rails.root + "routes.txt", "w") do |f|
              STDOUT.extend(IoInterceptor) unless STDOUT.respond_to?(:intercept)
              f.write(STDOUT.intercept { MyIrb.context.main.rake("routes") })
            end

            # puts "Rebuilt routes at #{ Time.now }"
          end

          last_mtime = cur_mtime
        rescue Exception => e
          puts "Exception while generating routes: #{ e.inspect }"
        end
      end
    end
  end
end