
component{

    this.name = "My Awesome App ToDoList";


	
    this.datasources["todolist"] = {
        class: "com.mysql.cj.jdbc.Driver", 
        bundleName: "com.mysql.cj", 
        bundleVersion: "9.3.0",
        connectionString: "jdbc:mysql://host.docker.internal:3306/TodoList?characterEncoding=UTF-8&serverTimezone=Etc/UTC&maxReconnects=3",
        username: "yasi",
        password: "encrypted:eb19967fea8cd005ee1ba7ae1ae1dcea8af85eb5f0bf37a177d9f43a999d26f6",
        
        // optional settings
        connectionLimit:-1, // default:-1
        liveTimeout:15, // default: -1; unit: minutes
        alwaysSetTimeout:true, // default: false
        validate:false // default: false
        
    };
    this.restsettings = {
        mapping = "/api",     
        path = expandPath("/var/www/api") 
    };


    
    function onRequest( string targetPage  ) {
         include "/index.cfm";
    }
    
}