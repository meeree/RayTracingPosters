#pragma once
#include <glad/glad.h>

GLuint LoadInShader(char const *fname, GLenum const &shaderType) 
{
    std::vector<char> buffer;
    std::ifstream in;
    in.open(fname, std::ios::binary);

    if(in.is_open()) 
	{
        in.seekg(0, std::ios::end);
        size_t const &length = in.tellg();

        in.seekg(0, std::ios::beg);

        buffer.resize(length + 1);
        in.read(&buffer[0], length);
        in.close();
        buffer[length] = '\0';
    } 
	else 
	{
        std::cerr<<"Unable to open "<<fname<<std::endl;
        exit(-1);
    }

    GLchar const *src = &buffer[0];

    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &src, NULL);
    glCompileShader(shader);
    GLint test;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &test);

    if(!test) 
	{
        std::cerr<<"Shader compilation failed with this message:"<<std::endl;
        std::vector<char> compilationLog(512);
        glGetShaderInfoLog(shader, compilationLog.size(), NULL, &compilationLog[0]);
        std::cerr<<&compilationLog[0]<<std::endl;
        exit(-1);
    }
    return shader;
}


GLuint LoadShaders(const char *vertLoc, const char *fragLoc)
{
    GLuint programID = glCreateProgram();
    GLuint vertShader = LoadInShader(vertLoc, GL_VERTEX_SHADER);
    GLuint fragShader = LoadInShader(fragLoc, GL_FRAGMENT_SHADER);

    glAttachShader(programID, vertShader);
    glAttachShader(programID, fragShader);

    glDeleteShader(vertShader);
    glDeleteShader(fragShader);

    glLinkProgram(programID);
    return programID;
}
