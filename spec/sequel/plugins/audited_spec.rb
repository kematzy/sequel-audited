require_relative "../../spec_helper"
require_relative "../../../lib/sequel/plugins/audited"

class CurrentUserMethodTest < Minitest::Spec

  describe "current_user" do
    let(:u1) { User[username: "joeblogs"]  }
    let(:u2) { User[username: "janeblogs"] }
    before do
      $current_user = u1
    end

    it "should by default return the default user - Joe Blogs" do
      current_user().must_equal u1
      current_user().id.must_be_kind_of(String) #uuid
      current_user().name.must_equal "Joe Blogs"
      current_user().username.must_equal "joeblogs"
    end

    it "should allow overriding the user and return the new current_user - Jane Blogs" do
      $current_user =           u2
      current_user().wont_equal u1
      current_user().must_equal u2
      current_user().name.must_equal "Jane Blogs"
      current_user().username.must_equal "janeblogs"
      $current_user = u1 # reset for next test
    end

  end

end

class AuditedUserMethodTest < Minitest::Spec

  describe "audited_user" do
    let(:jane)    { User[username: "janeblogs"]  }
    let(:auditor) { User[username: "auditeduser"]  }

    before do
      $audited_user = auditor
    end

    it "should by default return the default user - Audited User" do
      audited_user().must_equal auditor
      audited_user().name.must_equal "Audited User"
      audited_user().username.must_equal "auditeduser"
    end

    it "should allow overriding the user and return the new current_user - Jane Blogs" do
      $audited_user = jane
      audited_user().must_equal jane 
      audited_user().name.must_equal "Jane Blogs"
      audited_user().username.must_equal "janeblogs"
      $audited_user = auditor # reset for next test
    end

  end

end

class SequelAuditedPluginTest < Minitest::Spec

  describe "configuration" do

    describe "without options passed" do

      let(:jane) { User[username: "janeblogs"] }

      before do
        $current_user = jane
        class Post1 < Post; end
        Post1.plugin(:audited)
      end

      describe "#audited_columns" do

        it "should include all fields, excluding default ignored attributes" do
          Post1.audited_columns.must_equal [:id, :category_id, :title, :body, :urlslug, :author_id]
        end

      end

      describe "#non_audited_columns" do

        it "should include the default excluded attributes" do
          Post1.non_audited_columns.must_equal [:created_at, :updated_at]
        end

      end

      describe "#audited_default_ignored_columns" do

        [:lock_version, :created_at, :updated_at, :created_on, :updated_on].each do |m|
          it "should include: #{m}" do
            Post1.audited_default_ignored_columns.must_include(m)
          end
        end

      end

      describe "#audited_current_user_method" do

        it "should return the default value: :current_user" do
          Post1.audited_current_user_method.must_equal :current_user
        end

        it "should use the :current_user User for versions" do
          c = Post1.create(title: "Testing #audited_current_user_method")
          assert c.valid?
          v = c.versions.first
          v.username.must_equal jane.username
        end

      end

    end # /without options

    describe "with options" do

      describe "Post.plugin(:audited, :user_method => :audited_user)" do

        let(:jane) { User[username: "janeblogs"] }

        before do
          $audited_user = jane
          class Post2 < Post; end
          Post2.plugin(:audited, user_method: :audited_user)
        end

        it "#audited_current_user_method should return the custom value" do
          Post2.audited_current_user_method.must_equal :audited_user
        end

        it "should use the :audited_user User for versions" do
          c = Post2.create(title: "Testing #audited user_method: :audited_user")
          assert c.valid?
          v = c.versions.first
          v.username.must_equal "janeblogs"
        end

      end

      describe "Post.plugin(:audited, :only => ...)" do

        describe ":only => :title" do

          before do
            class Post3 < Post; end
            Post3.plugin(:audited, only: :title)
          end

          it "#.audited_columns should include only the named column" do
            Post3.audited_columns.must_equal [:title]
          end

          it "#.non_audited_columns should include all column except the named column" do
            Post3.non_audited_columns.must_equal(Post3.columns - [:title])
          end

          it "should only store a version when updating the :title" do
            p = Post3.create(title: "Post3 Testing versioned attr :title", body: "Post3 Body")
            p.versions.wont_equal []
            p.update(title: "Post3 Title Updated")
            p.save
            p.versions.count.must_equal 2
            v = p.versions.last
            v.changed.must_equal({"title"=>["Post3 Testing versioned attr :title", "Post3 Title Updated"]})
          end

          it "should NOT store a version when updating :body" do
            p = Post3.create(title: "Post3 Testing non versioned attribute :body", body: "Post3 Body")
            p.versions.count.must_equal 1
            p.update(body: "Post Body Updated")
            p.versions.count.must_equal 1
            v = p.versions.last
            v.event.must_equal "create"
          end

        end

        describe "only: [:title]" do

          before do
            class Post4 < Post; end
            Post4.plugin(:audited, only: [:title])
          end

          it "#.audited_columns should include only the named column" do
            Post4.audited_columns.must_equal [:title]
          end

          it "#.non_audited_columns should include all column except the named column" do
            Post4.non_audited_columns.must_equal(Post4.columns - [:title])
          end

        end

        describe "only: [:title, :author_id]" do
          let(:u1) { User[username: "joeblogs"]  }
          let(:u2) { User[username: "janeblogs"] }
      
          before do
            $current_user = u1
            $audited_user = u2
            class Post5 < Post; end
            Post5.plugin(:audited, only: [:title, :author_id])
          end

          it "#.audited_columns should include only the named columns" do
            [:author_id, :title].each { |m| Post5.audited_columns.must_include(m) }
          end

          it "#.non_audited_columns should include all column except the named columns" do
            Post5.non_audited_columns.must_equal([:id, :category_id, :body, :urlslug, :created_at, :updated_at])
          end

          it "#.versions should only store the :title for update versions" do
            p = Post5.create(title: "Post5 Testing only: [:title, :author_id]", body: "Post Body", author: current_user())
            p.versions.count.must_equal 1
            p.update(title: "Post5 Title Updated [:title, :author_id]", author: audited_user() )
            p.versions.count.must_equal 2
            v = p.versions.last
            v.changed.must_equal({"title"=>["Post5 Testing only: [:title, :author_id]", "Post5 Title Updated [:title, :author_id]"], "author_id" => [current_user.id, audited_user.id] })
          end

        end

      end

      describe "Post.plugin(:audited, :except => ...)" do

        describe ":except => :title" do

          let(:u1) { User[username: "joeblogs"]  }
          let(:u2) { User[username: "janeblogs"] }
      
          before do
            $current_user = u1
            $audited_user = u2
            class Post6 < Post; end
            Post6.plugin(:audited, except: :title)
          end

          it "#.audited_columns should include all columns except the named column" do
            [:id, :author_id, :category_id, :body, :urlslug].each { |m| Post6.audited_columns.must_include(m) }
          end

          it "#.non_audited_columns should include the named column" do
            [:title, :created_at, :updated_at].each { |m| Post6.non_audited_columns.must_include(m) }
          end

          it "should store a version with all attributes except :title after update" do
            p = Post6.create(title: "Post6 Testing updating versioned attributes :except => :title", body: "BlogPost Body")
            p.versions.count.must_equal 1
            p.update(body: "BlogPost Body Updated")
            p.versions.count.must_equal 2
            v = p.versions.last
            v.changed.must_equal({"body"=>["BlogPost Body", "BlogPost Body Updated"]})
          end
          
          it "should NOT store a version when updating :title" do
            p = Post6.create(title: "Post6 Testing non-versioned :title attribute", body: "BlogPost Body")
            p.versions.count.must_equal 1
            p.update(title: "BlogPost Title Updated")
            p.versions.count.must_equal 1
            v = p.versions.last
            v.event.must_equal "create"
          end

        end

        describe "except: [:title]" do
     
          before do
            class Post7 < Post; end
            Post7.plugin(:audited, except: [:title])
          end

          it "#.audited_columns should include all columns except the named column" do
            [:id, :author_id, :category_id, :body, :urlslug].each { |m| Post7.audited_columns.must_include(m) }
          end

          it "#.non_audited_columns should include the named column" do
            [:title, :created_at, :updated_at].each { |m| Post7.non_audited_columns.must_include(m) }
          end

        end

        describe "except: [:title,:author_id]" do
          let(:u1) { User[username: "joeblogs"]  }
          let(:u2) { User[username: "janeblogs"] }
      
          before do
            $current_user = u1
            $audited_user = u2
            class Post8 < Post; end
            Post8.plugin(:audited, except: [:title, :author_id])
          end
          
          it "#.audited_columns should include only the excepted columns" do
            [:id, :category_id, :body, :urlslug].each { |m| Post8.audited_columns.must_include(m) }
          end

          it "#.non_audited_columns should include the excluded columns" do
            [:title, :author_id, :created_at, :updated_at].each { |m| Post8.non_audited_columns.must_include(m) }
          end

        end

      end


      describe "Post.plugin(:audited, :default_ignored_columns => [])" do
        let(:u1) { User[username: "joeblogs"]  }
        let(:u2) { User[username: "janeblogs"] }
    
        before do
          $current_user = u1
          $audited_user = u2
          class Post9 < Post; end
          Post9.plugin(:audited, default_ignored_columns: [:title, :author_id])
        end

        it "#audited_default_ignored_columns should return the custom value" do
          [:title, :author_id].each { |m| Post9.audited_default_ignored_columns.must_include(m) }
        end

        it "#audited_columns should return the correct columns" do
          [:id, :category_id, :body, :urlslug, :created_at, :updated_at].each do |m| 
            Post9.audited_columns.must_include(m)
          end
        end

        it "#audited_ignored_columns should return the correct ignored columns" do
          [:title, :author_id].each { |m| Post9.audited_ignored_columns.must_include(m) }
        end

      end

    end

  end

  describe "An audited Model" do

    before do
      class Post10 < Post; end
      Post10.plugin(:audited, only: :title)
    end

    describe "Class Methods" do

      describe "#.audited_versions?" do

        before do
          # ::DB[:posts].delete
          # ::DB[:audit_logs].delete
        end

        describe "with NO saved versions" do
          
          before do
            class Post10 < Post; end
            Post10.plugin(:audited, only: :title)
          end

          it "should return false when no versions have been created" do
            Post10.audited_versions?.must_equal false
          end
          
        end
        
        describe "with saved versions" do
          
          before do
            class Post11 < Post; end
            Post11.plugin(:audited, only: :title)
          end

          it "should return true when one version have been created" do
            Post11.audited_versions?.must_equal false
            p = Post11.create(title: "Post12 Testing :audited_versions? with versions", body: "Post Body")
            p.versions.count.must_equal 1
            Post11.audited_versions?.must_equal true
          end
          
        end

        describe "with multiple saved versions" do
          
          before do
            class Post12 < Post; end
            Post12.plugin(:audited, only: :title)
          end

          it "should return true" do
            Post12.audited_versions?.must_equal false

            p = Post12.create(title: "Post12 Testing :audited_versions?() multiple", body: "Post Body")
            tmp_uuid = p.id
            p.versions.count.must_equal 1
            p.versions.last.version.must_equal 1
            Post12.audited_versions.count.must_equal 1


            p.title = "Post12 updated 2"
            p.save
            Post12.audited_versions.count.must_equal 2
            # forcing uncached query here
            p.versions(reload: true).count.must_equal 2
            p.versions.last.version.must_equal 2

            p.update(title: "Post12 updated 3")
            Post12.audited_versions.count.must_equal 3
            # forcing uncached query here
            p.versions(reload: true).count.must_equal 3
            p.versions.last.version.must_equal 3

            p.set_fields({title: "Post12 updated 4"}, [:title], missing: :skip)
            p.save

            Post12.audited_versions.count.must_equal 4
            # forcing uncached query here
            p.versions(reload: true).count.must_equal 4
            p.versions.last.version.must_equal 4

            # p.versions.map(&:version).must_equal(:debug)
            Post12.audited_versions?.must_equal true
          end

        end

      end

      describe "#.audited_versions" do

        describe "without options" do
          before do
            class ::Post13 < Post; end
            ::Post13.plugin(:audited, only: :title)
          end

          it "should return an empty array if no version exists, or an array of versions" do
            ::Post13.audited_versions.must_equal []

            a = ::Post13.create(title: "Post13 Testing #audited_versions method")
            ::Post13.audited_versions.wont_be_empty
            al = ::Post13.audited_versions.first
            al.must_be_kind_of(::AuditLog)
            al.item_type.must_equal "Post13"
            al.item_uuid.must_equal a.id
          end

        end

        describe "with options" do
          let(:joe)    { User[username: "joeblogs"]  }
          let(:auditor) { User[username: "auditeduser"]  }
      
          describe "(username: ??)" do

            before do
              $current_user = joe
              $audited_user = auditor
              class ::Post14 < Post; end
              ::Post14.plugin(:audited, only: :title)
            end
  
            it "should return an empty array when given a user without audits" do
              ::Post14.audited_versions(username: "janeblogs").must_equal []
              ::Post14.audited_versions(username: "janeblogs").count.must_equal 0
            end

            it "should return found audits when given a user with audits" do
              %w(a b c d).each do |n|
                ::Post14.create(title: "Post14 Testing :audited_versions(username: ??) #{n}", body: "Post Body")
              end
              ::Post14.audited_versions(username: "joeblogs").count.must_equal 4
            end

          end

          describe "(item_uuid: ??)" do
            
            before do
              $current_user = auditor
              class ::Post15 < Post; end
              ::Post15.plugin(:audited, only: :title)
            end
  
            it "should raise an ERROR when given an invalid model uuid key" do
              proc {
                ::Post15.audited_versions(item_uuid: "abc-123")
              }.must_raise Sequel::DatabaseError
            end

            it "should return an empty array when given a model uuid key without audits" do
              ::Post15.audited_versions(item_uuid: "9FB4650C-7440-4FD6-B48F-5E63E0CA4830").must_equal []
              ::Post15.audited_versions(item_uuid: "9FB4650C-7440-4FD6-B48F-5E63E0CA4830").count.must_equal 0
            end

            it "should return found audits when given an audited uuid key" do
              p = ::Post15.create(title: "Post14 Testing :audited_versions(item_uuid: ??)", body: "Post Body")
              ::Post15.audited_versions(item_uuid: p.id).count.must_equal 1
            end

          end

          describe "(created_at: ???)" do
            
            before do
              class ::Post16 < Post; end
              ::Post16.plugin(:audited, only: :title)
            end

            it "should return an empty array when given a time without audits" do
              ::Post16.audited_versions(created_at: Time.now - 1 ).must_equal []
              ::Post16.audited_versions(created_at: Time.now - 1 ).count.must_equal 0
            end

            it "should return an array when given a time with audits" do
              skip("TODO: have to add TimeCop here to test the time issues")

              ::Post16.audited_versions(created_at: Time.now).must_equal []
              ::Post16.audited_versions(created_at: Time.now).count.must_equal 1
            end

          end

        end

      end

    end

    describe "Instance Methods" do

      describe "#.blame (aliased as: #.last_audited_by)" do
        let(:joe)     { User[username: "joeblogs"]  }
        # let(:auditor) { User[username: "auditeduser"]  }
    
        describe "(username: ??)" do

          before do
            $current_user = joe
            # $audited_user = auditor
            class ::Post17 < Post; end
            ::Post17.plugin(:audited, only: :title)
          end

          it "should return 'not audited' if no previous version" do
            a = Post17.new
            a.blame.must_equal "not audited"
            a.last_audited_by.must_equal "not audited"
          end

          it "should return the username of the last version" do
            a = ::Post17.create(title: "Post17 Testing :blame", body: "Post Body")
            a.blame.must_equal "joeblogs" # default
            a.last_audited_by.must_equal "joeblogs"
          end

        end
      end

      describe "#.last_audited_at (aliased as: #.last_audited_on)" do
        let(:joe)     { User[username: "joeblogs"]  }

        before do
          $current_user = joe
          # $audited_user = auditor
          class ::Post18 < Post; end
          ::Post18.plugin(:audited, only: :title)
        end

        it "should return 'not audited' if no previous version" do
          a = ::Post18.new
          a.last_audited_at.must_equal "not audited"
          a.last_audited_on.must_equal "not audited"
        end

        it "should return the created_at time of the last version" do
          a = ::Post18.create(title: "Post1 Testing :last_audited_at", body: "Post Body")
          a.last_audited_at.must_be_kind_of(Time)
          a.last_audited_at.to_s.must_match(/#{Time.now.strftime("%Y-%m-%d")}/)
        end

      end

      describe "Hooks" do
        let(:joe)     { User[username: "joeblogs"]  }
        before do
          $current_user = joe
          Category.plugin(:audited, only: [:name])
        end

        describe "when creating a record, triggering #.after_create" do

          it "should save an audited version" do
            c = Category.new(name: "Category .after_create")
            c.versions.must_equal []
            c.versions.count.must_equal 0
            c.save
            c.versions.count.must_equal 1

            v = c.versions.first
            v.version.must_equal 1
            v.event.must_equal "create"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.id
            v.changed.wont_equal ''
            # v.changed.must_equal c.values.to_json
          end

        end

        describe "when updating a record, triggering #.after_update" do
          before do
            ::DB[:categories].delete
            ::AuditLog.where(item_type: "Category").destroy
          end

          it "should save an audited version with changes only" do
            c = Category.create(name: "Category .after_update")
            assert c.valid?
            c.versions.count.must_equal 1

            c.update(name: "Category .after_update updated")
            c.versions.count.must_equal 2

            v = c.versions.last
            v.version.must_equal 2
            v.event.must_equal "update"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.id
            # v.changed.to_json.must_equal :debug
            v.changed.to_json.must_match(/\"name\":\[\"Category .after_update\",\"Category .after_update updated\"\]/)
          end

        end


        describe "when destroying a record, triggering #.after_destroy" do
          before do
            ::DB[:categories].delete
            ::AuditLog.where(item_type: "Category").destroy
          end

          it "should save an audited version with all values" do
            c = Category.create(name: "Category .after_destroy")
            assert c.valid?
            c.versions.count.must_equal 1

            c.update(name: "Category .after_destroy updated")
            c.versions.count.must_equal 2

            c.destroy
            c.versions.count.must_equal 3

            v = c.versions.last
            # v.must_equal 'debug'
            v.version.must_equal 3
            v.event.must_equal "destroy"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.id
            # v.changed.to_json.must_equal :debug_values_to_json
            v.changed.to_json.must_equal c.values.to_json
          end

        end

      end

    end

    describe "should have associated versions" do

      let(:u) { User.create(username: "johnblogs", name: "John Blogs", email: "john@blogs.com") }
       
      before do
        $current_user = u
        Author.plugin(:audited, only: :name)
      end
      
      it { assert_association_one_to_many(Author.new, :versions) }

      it "should store the current user :username for each version" do
        a = Author.create(name: "Kematzy ")
        v = a.versions.first
        v.username.must_equal u.username #"johnblogs"
      end

      it "should store the current user :id for each version" do
        # $current_user = User[2]  # jane
        a = Author.create(name: "Kematzy 2")
        v = a.versions.first
        v.user_id.must_equal u.id
      end

      it "should not store versions for unsaved models" do
        m = Author.new
        m.versions.count.must_equal 0
        m.versions.must_equal []
      end

    end

  end


  describe "with Custom user method" do
    let(:u1) { User[username: "joeblogs"]  }
    let(:u2) { User[username: "janeblogs"] }

    before do
      $current_user = u1
      $audited_user = u2
      Author.plugin(:audited, only: :name, user_method: :audited_user)
    end

    it "should" do
      # ::AuditLog.audited_current_user_method = :audited_user
      a = Author.create(name: "Kematzy 11")
      v = a.versions.first
      v.username.must_equal "janeblogs"
      # ::AuditLog.audited_current_user_method = :current_user
    end

  end

  describe "invalid current_user_method" do
    before do
      class ::Post21 < Post; end
      ::Post21.plugin(:audited, user_method: :does_not_exist)
    end

    it "should handle a missing/invalid :user_method by using default values" do
      p = ::Post21.create(title: "Post21 Testing invalid user method", body: "Post body")
      assert p.valid?
      v = p.versions.first
      v.user_id.must_equal "394d9d14-0c8c-4711-96c1-2c3fc90dd671"
      v.username.must_equal "system"
      v.user_type.must_equal "OpenStruct"
    end
  
  end
end

