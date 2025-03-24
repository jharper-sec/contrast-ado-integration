package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;

/**
 * Example application with deliberate security vulnerabilities
 * for demonstration of Contrast Security scanning.
 * 
 * DO NOT USE THIS CODE IN PRODUCTION - it contains multiple security issues!
 */
@SpringBootApplication
@RestController
@Slf4j
public class App {
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
    
    /**
     * Example endpoint with SQL Injection vulnerability
     */
    @GetMapping("/users")
    public List<Map<String, Object>> getUser(@RequestParam String username) {
        // SECURITY ISSUE: SQL Injection vulnerability
        String sql = "SELECT * FROM users WHERE username = '" + username + "'";
        return jdbcTemplate.queryForList(sql);
    }
    
    /**
     * Example endpoint with XSS vulnerability
     */
    @GetMapping("/message")
    public String getMessage(@RequestParam String message) {
        // SECURITY ISSUE: XSS vulnerability
        return "<div>Message: " + message + "</div>";
    }
    
    /**
     * Example endpoint with Insecure Cookie
     */
    @GetMapping("/login")
    public String login(HttpServletResponse response, @RequestParam String username) {
        // SECURITY ISSUE: Insecure cookie
        Cookie cookie = new Cookie("auth", username);
        cookie.setPath("/");
        // SECURITY ISSUE: Missing secure flag
        // cookie.setSecure(true);
        // SECURITY ISSUE: Missing httpOnly flag
        // cookie.setHttpOnly(true);
        response.addCookie(cookie);
        return "Logged in as: " + username;
    }
    
    /**
     * Example endpoint with Path Traversal vulnerability
     */
    @GetMapping("/file")
    public String getFile(@RequestParam String filename) throws IOException {
        // SECURITY ISSUE: Path Traversal vulnerability
        java.io.File file = new java.io.File(filename);
        byte[] fileContent = java.nio.file.Files.readAllBytes(file.toPath());
        return new String(fileContent);
    }
    
    /**
     * Example endpoint with hardcoded credentials
     */
    @GetMapping("/connect")
    public String connectToDatabase() throws SQLException {
        // SECURITY ISSUE: Hardcoded credentials
        String dbUrl = "jdbc:mysql://localhost:3306/mydb";
        String dbUser = "admin";
        String dbPassword = "Password123!";
        
        // Simulate connection
        log.info("Connecting to database with url: {}", dbUrl);
        return "Connected to database";
    }
    
    /**
     * Example endpoint with Command Injection vulnerability
     */
    @GetMapping("/execute")
    public String executeCommand(@RequestParam String command) throws IOException {
        // SECURITY ISSUE: Command Injection vulnerability
        Process process = Runtime.getRuntime().exec(command);
        java.io.BufferedReader reader = new java.io.BufferedReader(
            new java.io.InputStreamReader(process.getInputStream()));
        
        StringBuilder output = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            output.append(line).append("\n");
        }
        
        return output.toString();
    }
}
