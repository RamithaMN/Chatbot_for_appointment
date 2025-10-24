-- ================================================================
-- Dental Chatbot Database Seed Data
-- PostgreSQL 15+
-- ================================================================

-- ================================================================
-- DEMO USERS
-- ================================================================

-- Insert demo users (passwords are bcrypt hashed versions of 'demo123' and 'admin123')
INSERT INTO users (username, email, password_hash, full_name, phone, role) VALUES
('demo', 'demo@example.com', '$2b$12$hLUsVYTWOIBfIM8Qrx8Nh.wzP6wCGbat5OpwULDYp5KV/6PP4vki2', 'Demo User', '555-0101', 'patient'),
('admin', 'admin@example.com', '$2b$12$t/OvQZ/qKMQR5mfbiliW2uAtfHIRjdEb5HQ55W1CJgtLRjZE6dWhe', 'Admin User', '555-0100', 'admin'),
('dr_smith', 'dr.smith@dental.com', '$2b$12$hLUsVYTWOIBfIM8Qrx8Nh.wzP6wCGbat5OpwULDYp5KV/6PP4vki2', 'Dr. Sarah Smith', '555-0201', 'dentist'),
('dr_jones', 'dr.jones@dental.com', '$2b$12$hLUsVYTWOIBfIM8Qrx8Nh.wzP6wCGbat5OpwULDYp5KV/6PP4vki2', 'Dr. Michael Jones', '555-0202', 'dentist'),
('john_doe', 'john.doe@email.com', '$2b$12$hLUsVYTWOIBfIM8Qrx8Nh.wzP6wCGbat5OpwULDYp5KV/6PP4vki2', 'John Doe', '555-1001', 'patient'),
('jane_smith', 'jane.smith@email.com', '$2b$12$hLUsVYTWOIBfIM8Qrx8Nh.wzP6wCGbat5OpwULDYp5KV/6PP4vki2', 'Jane Smith', '555-1002', 'patient');

-- ================================================================
-- DEMO APPOINTMENTS
-- ================================================================

-- Get tenant_id (using demo user's ID as tenant for simplicity)
DO $$
DECLARE
    demo_tenant_id UUID;
    demo_user_id UUID;
    dr_smith_id UUID;
    dr_jones_id UUID;
    john_doe_id UUID;
    jane_smith_id UUID;
BEGIN
    -- Get user IDs
    SELECT id INTO demo_user_id FROM users WHERE username = 'demo';
    SELECT id INTO dr_smith_id FROM users WHERE username = 'dr_smith';
    SELECT id INTO dr_jones_id FROM users WHERE username = 'dr_jones';
    SELECT id INTO john_doe_id FROM users WHERE username = 'john_doe';
    SELECT id INTO jane_smith_id FROM users WHERE username = 'jane_smith';
    
    -- Use demo user's ID as tenant_id
    demo_tenant_id := demo_user_id;
    
    -- Insert sample appointments
    INSERT INTO appointments (tenant_id, patient_id, patient_name, patient_email, patient_phone, appointment_date, appointment_time, 
        appointment_type, dentist_id, dentist_name, status, reason_for_visit) 
    VALUES 
    (demo_tenant_id, demo_user_id, 'Demo User', 'demo@example.com', '555-0101', 
     CURRENT_DATE + INTERVAL '3 days', '10:00:00', 'checkup', dr_smith_id, 'Dr. Sarah Smith', 
     'scheduled', 'Regular 6-month checkup'),
    
    (demo_tenant_id, john_doe_id, 'John Doe', 'john.doe@email.com', '555-1001', 
     CURRENT_DATE + INTERVAL '5 days', '14:00:00', 'cleaning', dr_jones_id, 'Dr. Michael Jones', 
     'confirmed', 'Teeth cleaning and fluoride treatment'),
    
    (demo_tenant_id, jane_smith_id, 'Jane Smith', 'jane.smith@email.com', '555-1002', 
     CURRENT_DATE - INTERVAL '2 days', '15:30:00', 'filling', dr_smith_id, 'Dr. Sarah Smith', 
     'completed', 'Cavity filling on lower left molar'),
    
    (demo_tenant_id, demo_user_id, 'Demo User', 'demo@example.com', '555-0101', 
     CURRENT_DATE + INTERVAL '7 days', '09:30:00', 'consultation', dr_jones_id, 'Dr. Michael Jones', 
     'scheduled', 'Orthodontic consultation'),
    
    (demo_tenant_id, john_doe_id, 'John Doe', 'john.doe@email.com', '555-1001', 
     CURRENT_DATE + INTERVAL '10 days', '11:00:00', 'whitening', dr_smith_id, 'Dr. Sarah Smith', 
     'confirmed', 'Teeth whitening treatment');
END $$;

-- ================================================================
-- DEMO CHAT SESSIONS
-- ================================================================

-- Insert sample chat sessions
DO $$
DECLARE
    demo_user_id UUID;
    john_doe_id UUID;
    demo_tenant_id UUID;
    session_1_id UUID;
    session_2_id UUID;
    appointment_1_id UUID;
BEGIN
    -- Get user IDs
    SELECT id INTO demo_user_id FROM users WHERE username = 'demo';
    SELECT id INTO john_doe_id FROM users WHERE username = 'john_doe';
    demo_tenant_id := demo_user_id;
    
    -- Get an appointment ID for the chat session
    SELECT id INTO appointment_1_id FROM appointments WHERE patient_id = demo_user_id LIMIT 1;
    
    -- Insert chat sessions
    INSERT INTO chat_sessions (user_id, username, session_token, message_count, status, primary_intent, appointment_created, appointment_id)
    VALUES 
    (demo_user_id, 'demo', 'session_' || uuid_generate_v4(), 8, 'ended', 'appointment_scheduling', true, appointment_1_id),
    (john_doe_id, 'john_doe', 'session_' || uuid_generate_v4(), 5, 'ended', 'service_inquiry', false, NULL)
    RETURNING id INTO session_1_id;
    
    -- Insert sample chat messages for the first session
    INSERT INTO chat_messages (session_id, role, message_text, tokens_used, response_time_ms, llm_model, detected_intent, intent_confidence, sequence_number)
    VALUES 
    (session_1_id, 'user', 'Hi, I need to book an appointment', 8, 150, 'gpt-3.5-turbo', 'appointment_scheduling', 0.95, 1),
    (session_1_id, 'bot', 'Hello! I''d be happy to help you schedule an appointment. What''s your name?', 15, 200, 'gpt-3.5-turbo', 'appointment_scheduling', 0.90, 2),
    (session_1_id, 'user', 'My name is Demo User', 6, 120, 'gpt-3.5-turbo', 'appointment_scheduling', 0.88, 3),
    (session_1_id, 'bot', 'Thank you Demo User! What''s the reason for your visit?', 12, 180, 'gpt-3.5-turbo', 'appointment_scheduling', 0.92, 4),
    (session_1_id, 'user', 'I need a regular checkup', 7, 110, 'gpt-3.5-turbo', 'appointment_scheduling', 0.85, 5),
    (session_1_id, 'bot', 'Perfect! What''s your preferred date and time?', 10, 160, 'gpt-3.5-turbo', 'appointment_scheduling', 0.90, 6),
    (session_1_id, 'user', 'How about next Tuesday at 10 AM?', 8, 130, 'gpt-3.5-turbo', 'appointment_scheduling', 0.88, 7),
    (session_1_id, 'bot', 'Great! I have you scheduled for Tuesday at 10:00 AM. Your appointment is confirmed!', 18, 220, 'gpt-3.5-turbo', 'appointment_scheduling', 0.95, 8);
    
    -- Insert sample chat messages for the second session
    INSERT INTO chat_messages (session_id, role, message_text, tokens_used, response_time_ms, llm_model, detected_intent, intent_confidence, sequence_number)
    VALUES 
    (session_1_id + 1, 'user', 'What are your office hours?', 6, 140, 'gpt-3.5-turbo', 'service_inquiry', 0.90, 1),
    (session_1_id + 1, 'bot', 'Our office hours are Monday through Friday from 8:00 AM to 6:00 PM, and Saturday from 9:00 AM to 2:00 PM.', 25, 190, 'gpt-3.5-turbo', 'service_inquiry', 0.95, 2),
    (session_1_id + 1, 'user', 'Do you accept insurance?', 5, 100, 'gpt-3.5-turbo', 'service_inquiry', 0.85, 3),
    (session_1_id + 1, 'bot', 'Yes, we accept most major insurance plans. Would you like to schedule a consultation to discuss your coverage?', 20, 210, 'gpt-3.5-turbo', 'service_inquiry', 0.88, 4),
    (session_1_id + 1, 'user', 'Not right now, thanks!', 4, 80, 'gpt-3.5-turbo', 'service_inquiry', 0.75, 5);
    
    -- Update the second session with feedback
    UPDATE chat_sessions 
    SET feedback_rating = 5, feedback_text = 'Very helpful and responsive!'
    WHERE id = session_1_id + 1;
    
END $$;

-- ================================================================
-- DEMO AUDIT LOG ENTRIES
-- ================================================================

-- Insert sample audit log entries
DO $$
DECLARE
    demo_user_id UUID;
    admin_user_id UUID;
    dr_smith_id UUID;
BEGIN
    -- Get user IDs
    SELECT id INTO demo_user_id FROM users WHERE username = 'demo';
    SELECT id INTO admin_user_id FROM users WHERE username = 'admin';
    SELECT id INTO dr_smith_id FROM users WHERE username = 'dr_smith';
    
    -- Insert audit log entries
    INSERT INTO audit_log (user_id, username, action, resource_type, resource_id, ip_address, user_agent, request_method, request_path, status, new_values)
    VALUES 
    (demo_user_id, 'demo', 'user_login', 'user', demo_user_id, '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'POST', '/api/auth/login', 'success', '{"login_time": "2025-01-23T10:30:00Z"}'),
    
    (demo_user_id, 'demo', 'appointment_created', 'appointment', (SELECT id FROM appointments WHERE patient_id = demo_user_id LIMIT 1), '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'POST', '/api/appointments', 'success', '{"appointment_type": "checkup", "date": "2025-01-26", "time": "10:00:00"}'),
    
    (admin_user_id, 'admin', 'user_created', 'user', demo_user_id, '192.168.1.50', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36', 'POST', '/api/admin/users', 'success', '{"username": "demo", "role": "patient"}'),
    
    (dr_smith_id, 'dr_smith', 'appointment_confirmed', 'appointment', (SELECT id FROM appointments WHERE dentist_id = dr_smith_id LIMIT 1), '192.168.1.75', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36', 'PUT', '/api/appointments/confirm', 'success', '{"status": "confirmed", "confirmed_at": "2025-01-23T14:30:00Z"}');
    
END $$;

-- ================================================================
-- COMPLETION MESSAGE
-- ================================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Dental Chatbot Database seeded successfully!';
    RAISE NOTICE 'Demo users created: demo, admin, dr_smith, dr_jones, john_doe, jane_smith';
    RAISE NOTICE 'Demo appointments created: 5';
    RAISE NOTICE 'Demo chat sessions created: 2';
    RAISE NOTICE 'Demo chat messages created: 13';
    RAISE NOTICE 'Demo audit log entries created: 4';
    RAISE NOTICE '========================================';
END $$;
