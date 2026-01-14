-- MySQL 8.0 schema - all tables needed for the application

-- User table
CREATE TABLE IF NOT EXISTS `user` (
    id VARCHAR(255) PRIMARY KEY,
    name TEXT NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(255),
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    profile_image_url TEXT NOT NULL,
    bio TEXT,
    gender VARCHAR(50),
    date_of_birth VARCHAR(50),
    info TEXT,
    settings TEXT,
    api_key VARCHAR(255) UNIQUE,
    oauth_sub VARCHAR(255) UNIQUE,
    last_active_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    created_at BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_user_email ON `user`(email);
CREATE INDEX IF NOT EXISTS idx_user_api_key ON `user`(api_key);

-- Auth table
CREATE TABLE IF NOT EXISTS auth (
    id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password TEXT NOT NULL,
    active TINYINT NOT NULL DEFAULT 1,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_auth_email ON auth(email);

-- Chat table
CREATE TABLE IF NOT EXISTS chat (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    title TEXT NOT NULL,
    chat TEXT NOT NULL,
    folder_id VARCHAR(255),
    archived TINYINT NOT NULL DEFAULT 0,
    pinned TINYINT DEFAULT 0,
    share_id VARCHAR(255) UNIQUE,
    meta TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_chat_user_id ON chat(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_share_id ON chat(share_id);
CREATE INDEX IF NOT EXISTS idx_chat_updated_at ON chat(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_created_at ON chat(created_at DESC);

-- Message table (with support for both chat and channel messages)
CREATE TABLE IF NOT EXISTS message (
    id VARCHAR(255) PRIMARY KEY,
    chat_id VARCHAR(255),
    user_id VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    role VARCHAR(50),
    model VARCHAR(255),
    meta TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    channel_id VARCHAR(255),
    reply_to_id VARCHAR(255),
    parent_id VARCHAR(255),
    data TEXT,
    FOREIGN KEY (chat_id) REFERENCES chat(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_message_chat_id ON message(chat_id);
CREATE INDEX IF NOT EXISTS idx_message_channel_id ON message(channel_id);
CREATE INDEX IF NOT EXISTS idx_message_parent_id ON message(parent_id);

-- Message reaction table
CREATE TABLE IF NOT EXISTS message_reaction (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    message_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
    FOREIGN KEY (message_id) REFERENCES message(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_message_reaction_message_id ON message_reaction(message_id);
CREATE INDEX IF NOT EXISTS idx_message_reaction_user_id ON message_reaction(user_id);

-- Model table
CREATE TABLE IF NOT EXISTS model (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    base_model_id VARCHAR(255),
    name TEXT NOT NULL,
    params TEXT NOT NULL,
    meta TEXT,
    access_control TEXT,
    is_active TINYINT NOT NULL DEFAULT 1,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_model_user_id ON model(user_id);

-- Prompt table
CREATE TABLE IF NOT EXISTS prompt (
    command VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    access_control TEXT,
    meta TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_prompt_user_id ON prompt(user_id);

-- Tool table
CREATE TABLE IF NOT EXISTS tool (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name TEXT NOT NULL,
    content TEXT NOT NULL,
    specs TEXT NOT NULL,
    meta TEXT,
    access_control TEXT,
    valves TEXT DEFAULT '{}',
    is_active TINYINT NOT NULL DEFAULT 1,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_tool_user_id ON tool(user_id);

-- Function table
CREATE TABLE IF NOT EXISTS function (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name TEXT NOT NULL,
    type VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    meta TEXT,
    valves TEXT,
    is_active TINYINT NOT NULL DEFAULT 1,
    is_global TINYINT NOT NULL DEFAULT 0,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_function_user_id ON function(user_id);

-- File table
CREATE TABLE IF NOT EXISTS file (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    filename TEXT NOT NULL,
    path TEXT NOT NULL,
    meta TEXT,
    data TEXT,
    access_control TEXT,
    hash VARCHAR(255),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_file_user_id ON file(user_id);

-- Folder table
CREATE TABLE IF NOT EXISTS folder (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name TEXT NOT NULL,
    parent_id VARCHAR(255),
    is_expanded TINYINT DEFAULT 0,
    meta TEXT,
    data TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES folder(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_folder_user_id ON folder(user_id);
CREATE INDEX IF NOT EXISTS idx_folder_parent_id ON folder(parent_id);

-- Knowledge table
CREATE TABLE IF NOT EXISTS knowledge (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    data TEXT,
    meta TEXT,
    access_control TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_knowledge_user_id ON knowledge(user_id);

-- Memory table
CREATE TABLE IF NOT EXISTS memory (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    meta TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_memory_user_id ON memory(user_id);

-- Note table
CREATE TABLE IF NOT EXISTS note (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    title TEXT NOT NULL,
    data TEXT,
    meta TEXT,
    access_control TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_note_user_id ON note(user_id);

-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    version INT NOT NULL DEFAULT 0,
    type VARCHAR(100) NOT NULL,
    data TEXT,
    meta TEXT,
    snapshot TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON feedback(type);

-- Group table
CREATE TABLE IF NOT EXISTS `group` (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    data TEXT,
    meta TEXT,
    permissions TEXT,
    user_ids TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_group_user_id ON `group`(user_id);

-- Channel table
CREATE TABLE IF NOT EXISTS channel (
    id VARCHAR(255) PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    user_id VARCHAR(255) NOT NULL,
    data TEXT,
    meta TEXT,
    access_control TEXT,
    type VARCHAR(100),
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_channel_user_id ON channel(user_id);

-- Channel member table
CREATE TABLE IF NOT EXISTS channel_member (
    id VARCHAR(255) PRIMARY KEY,
    channel_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    created_at BIGINT NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES channel(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_channel_member_channel_id ON channel_member(channel_id);
CREATE INDEX IF NOT EXISTS idx_channel_member_user_id ON channel_member(user_id);

-- Tag table
CREATE TABLE IF NOT EXISTS tag (
    id VARCHAR(255) PRIMARY KEY,
    name TEXT NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    data TEXT,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES `user`(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_tag_user_id ON tag(user_id);

-- Config table for persistent configuration
CREATE TABLE IF NOT EXISTS config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    data TEXT NOT NULL DEFAULT '{}',
    version INT NOT NULL DEFAULT 0,
    created_at BIGINT NOT NULL,
    updated_at BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX IF NOT EXISTS idx_config_updated_at ON config(updated_at DESC);
