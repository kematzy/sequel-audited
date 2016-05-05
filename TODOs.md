# TODO's 


1. Spec bug: some tests runs fails with this error message:

    ```
      1) Failure:
    configuration::with options::Post.plugin(:audited, :only => ...)::only: [:title, :author_id]#test_0003_#.versions 
    should only store the :title for update versions [/Users/kematzy/.rbenv/versions/2.3.0/lib/ruby/2.3.0/delegate.rb:341]:
    --- expected
    +++ actual
    @@ -1 +1 @@
    -{"title"=>"Post Title Updated", "author_id"=>3}
    +{"title"=>"Post Title Updated"}
    ```
    
2. Add more tests with different models to ensure data is stored / ignored correctly during updates.


3. Add demo website and host demo on Heroku




