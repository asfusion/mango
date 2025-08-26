component {
    function create( admin, authorId, assetPath, email, category, name ){
        var basepage = {
            publish = true,
            authorId = authorId,
            allowComments = false,
            content = ''
        };

        admin.saveTemplateBlocks( 'home', [{"values" = {"text"="Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.","image"="","action"="##","action-label"="Sign up","subtitle"="Best hosting service","title"="Powerful web hosting"},"id"="hero","active"="1"},{"values":{"input-name"="search-term","text"="Get a new domain with us","input-placeholder"="Search","form-action"="","title"="Search for a domain"},"id"="search","active"="1"},{"values":{"items":[{"icon"="1","text"="Primis curabitur massa aptent torquent netus, at neque convallis etiam. Natoque conubia tellus conubia justo rhoncus elit. ","title"="Commitment to clean code"},{"icon"="2","text"="Sagittis finibus semper commodo varius dapibus eros egestas orci. Lectus convallis etiam tellus donec netus. ","title"="Customer support"},{"icon"="3","text"="Proin tincidunt pellentesque, vulputate ut venenatis nibh. Neque mattis fusce vivamus nisl eros; sollicitudin hac. ","title"="Bootstrap based"},{"icon"="4","text"="Ligula curabitur maecenas augue arcu orci. Neque mattis fusce vivamus nisl eros; sollicitudin hac. ","title"="Deployment ready"},{"icon"="5","text"="Facilisi tristique adipiscing erat suspendisse dui leo inceptos. Cursus augue finibus et lacinia nibh vestibulum.","title"="Security enhanced"},{"icon"="6","text"="Arcu fringilla fermentum dictumst nostra praesent? Quisque vehicula blandit orci fames auctor nibh blandit.","title"="100% guaranteed"}],"title"="Great features"},"id"="features","active"="1"},{"values":{"text"="Bibendum adipiscing pharetra duis proin tristique morbi hendrerit venenatis blandit. Netus himenaeos pellentesque consectetur suscipit efficitur non dis. Inceptos amet in purus molestie natoque neque. ","packages":[{"package-features":[{"text"="2TB of space"},{"text"="Semper risus"},{"text"="Placerat felis "}],"price"="10","button-url"="##","title"="Basic","button-label"="Get Started","price-frequency"="month"},{"package-features":[{"text"="3TB of space"},{"text"="Placerat felis "}],"price"="20","button-url"="##","title"="Medium","button-label"="Get Started","price-frequency"="month"},{"package-features":[{"text"="10TB of space"}],"price"="30","button-url"="##","title"="Advanced","button-label"="Get Started","price-frequency"="month"}],"title"="Best pricing around"},"id"="pricing","active"="1"},{"values":{"text"="Supercharge your Mango hosting with detailed website analytics, marketing tools. Our experts are just part of the reason Bluehost is the ideal home for your Mango website. We''re here to help you succeed!","items":[{"text"="Feature 1"},{"text"="Bibendum adipiscing pharetra "}],"image"="","title"="Global server location"},"id"="text-image-left","active"="1"},{"values":{"text"=" Placerat felis orci pulvinar habitasse rutrum vestibulum pulvinar gravida in. Arcu fringilla fermentum dictumst nostra praesent? Quisque vehicula blandit orci fames auctor nibh blandit.","button-url"="","items":[{"text"="Senectus lacus fermentum "},{"text"="Ex nostra montes dis habitasse"}],"image"="","title"="Dedicated support","button-label"="Call us at 121-212-1212"},"id"="text-image-right","active"="1"},{"values":{"text"="<p>Our experts are just part of the reason we are the ideal home for your website. We''re here to help you succeed!</p>","button-url"="##","items":[{"question"="How can I make my website work without www. in front?","answer"="Aliquam habitasse eu porta; hendrerit faucibus habitant. Montes vehicula nunc mauris bibendum id. Elit potenti nullam habitant sollicitudin faucibus molestie!"},{"question"="What domain name should I choose for my site?","answer"="Ex nostra montes dis habitasse class amet aptent primis ipsum. Aenean torquent massa "}],"title"="Frequently asked questions","button-label"="Contact us"},"id"="faqs","active"="1"},{"values":{"text"="","button-url"="","items":[],"title"="","button-label"=""},"id"="faqs-2","active":false},{"values":{"items":[{"photo"="","text"="Class hac fringilla mus facilisi taciti suscipit curae finibus. Dis arcu conubia habitasse urna adipiscing mollis. Nisi et interdum nascetur vestibulum cras eleifend facilisis montes pulvinar.","name"="John Miller","title"="CTO"}]},"id"="testimonials","active"="1"}] );

        //pages, posts and images
        var post = {
            title = "This is a headline",
            excerpt = "<p>This is a post with a featured image and a video. Aenean ornare velit lacus varius enim ullamcorper proin aliquam
facilisis ante sed etiam magna interdum congue. Lorem ipsum dolor
amet nullam sed etiam veroeros.</p>",
            content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>",
            publish = true,
            authorId = authorId,
            allowComments = true,
            postedOn = dateadd( 'd', -1, now() ),
            customFields = {  'image' = { 'key' = 'image', name = 'Featured Image', value = '#assetPath#images/pic1.jpg' }
            },
            categories = [ category.getId() ]
        };

        var result = admin.newPost( argumentcollection = post );

        for ( var i = 2; i LTE 5; i++) {
            post = {
                title = "Sed magna ipsum faucibus",
                excerpt = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis magna etiam.</p>",
                content = "<p>Donec eget ex magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. Pellentesque venenatis dolor imperdiet dolor mattis sagittis. Praesent rutrum sem diam, vitae egestas enim auctor sit amet. Pellentesque leo mauris, consectetur id ipsum sit amet, fergiat. Pellentesque in mi eu massa lacinia malesuada et a elit. Donec urna ex, lacinia in purus ac, pretium pulvinar mauris. Nunc lorem mauris, fringilla in aliquam at, euismod in lectus. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur sapien risus, commodo eget turpis at, elementum convallis enim turpis, lorem ipsum dolor sit amet nullam.</p>",
                publish = true,
                authorId = authorId,
                allowComments = true,
                postedOn = dateadd('d', -#i#, now()),
                customFields = { 'image' = { 'key' = 'image',
                    name = 'Featured Image', value = '#assetPath#images/pic#i#.jpg' } },
                categories = [ category.getId() ]
            };

            result = admin.newPost(argumentcollection = post);
        }

        var post = duplicate( basepage );
        post.title = "News";
        post.template = 'blog.cfm';
        post.sortOrder = 2;
        result = admin.newPage( argumentcollection = post );

        post.title = "Packages";
        post.template = 'page_blocks.cfm';
        post.sortOrder = 1;

        var customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{"text":"Bibendum adipiscing pharetra duis proin tristique morbi hendrerit venenatis blandit. Netus himenaeos pellentesque consectetur suscipit efficitur non dis. Inceptos amet in purus molestie natoque neque. ","packages":[{"package-features":[{"text":"2TB of space"},{"text":"Semper risus"},{"text":"Placerat felis "}],"price":"10","button-url":"##","title":"Basic","button-label":"Get Started","price-frequency":"month"},{"package-features":[{"text":"3TB of space"},{"text":"Placerat felis "}],"price":"20","button-url":"##","title":"Medium","button-label":"Get Started","price-frequency":"month"},{"package-features":[{"text":"10TB of space"}],"price":"30","button-url":"##","title":"Advanced","button-label":"Get Started","price-frequency":"month"}],"title":"Best pricing around"},"id":"pricing","active":"1"}]' };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );

        post.title = "Contact us";
        post.sortOrder = 5;

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"values":{},"id":"header","active":"1"},{"values":{},"id":"content","active":false},{"values":{"phone-2":"Mon to Fri 9am to 6pm","address-2":"Los Angeles, CA 90045","form-action":"","email-2":"Send us an email","phone":"123-233-2345","title":"Contact us","address":"123 Piquillin Road","email":"#email#"},"id":"contact","active":"1"},{"values":{"text":"","image":"","action":"##","action-label":"Sign up","subtitle":"","title":""},"id":"hero","active":false},{"values":{"input-name":"search-term","text":"","input-placeholder":"Search","form-action":"","title":""},"id":"search","active":false},{"values":{"items":[],"title":""},"id":"features","active":false},{"values":{"text":"","packages":[],"title":""},"id":"pricing","active":false},{"values":{"text":"","items":[],"image":"","title":""},"id":"text-image-left","active":false},{"values":{"text":"","button-url":"","items":[],"image":"","title":"","button-label":""},"id":"text-image-right","active":false},{"values":{"text":"","button-url":"","items":[],"title":"","button-label":""},"id":"faqs-2","active":false},{"values":{"text":"","button-url":"","items":[],"title":"","button-label":""},"id":"faqs","active":false},{"values":{"items":[]},"id":"testimonials","active":false},{"values":{},"id":"content-2","active":false}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );

        post.title = "Help";
        post.sortOrder = 3;

        customFields = { 'key' = 'blocks',
            name = 'Blocks', value = '[{"id"="header","active"="1", "values":{}},{"values":{"text"="<p>Our experts are just part of the reason we are the ideal home for your website. We''re here to help you succeed!</p>","button-url"="##","items":[{"question"="How can I make my website work without www. in front?","answer"="Aliquam habitasse eu porta; hendrerit faucibus habitant. Montes vehicula nunc mauris bibendum id. Elit potenti nullam habitant sollicitudin faucibus molestie!"},{"question"="What domain name should I choose for my site?","answer"="Ex nostra montes dis habitasse class amet aptent primis ipsum. Aenean torquent massa "}],"title"="Frequently asked questions","button-label"="Contact us"},"id"="faqs-2","active"="1"}]'
        };

        result = admin.newPage( argumentcollection = post );
        admin.setPageCustomField( result.newPage.getId(), customFields );
        admin.saveSetting( 'site/info', 'menu-button-label', 'Sign up' );
        admin.saveSetting( 'site/info', 'logo', '#assetPath#images/logo.png' );
        admin.saveSetting( 'site/info', 'newsletter-enabled', '1' );
        admin.saveSetting( 'site/info', 'newsletter-intro', 'Get notified of updates' );

        return result;
    }
}