CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    participant_one UUID REFERENCES users(id),
    participant_two UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO conversations (id, participant_one, participant_two)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '48cc4fc9-6a84-4e73-8b18-7571ba9ef216', 'ad75bb34-d039-44d6-b403-e76012631127');

INSERT INTO messages (id, conversation_id, sender_id, content, created_at) VALUES
  ('11111111-aaaa-bbbb-cccc-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '48cc4fc9-6a84-4e73-8b18-7571ba9ef216', 'Hello there!', NOW()),
  ('11111111-aaaa-bbbb-cccc-000000000002', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'ad75bb34-d039-44d6-b403-e76012631127', 'Hi! What''s up?', NOW() + INTERVAL '1 minute'),
  ('11111111-aaaa-bbbb-cccc-000000000003', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '48cc4fc9-6a84-4e73-8b18-7571ba9ef216', 'Just testing this app.', NOW() + INTERVAL '2 minutes');
  
  CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    contact_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, contact_id)
);

CREATE TABLE user_refresh_tokens (
  id SERIAL PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP, -- optional: nếu bạn muốn token tự hết hạn
  device_info TEXT -- optional: lưu thiết bị, IP, v.v.
);

CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);