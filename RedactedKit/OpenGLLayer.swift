//
//  OpenGLLayer.swift
//  Redacted
//
//  Created by Sam Soffes on 5/3/15.
//  Copyright (c) 2015 Nothing Magical Inc. All rights reserved.
//

import Foundation
import OpenGLES
import QuartzCore

public class OpenGLLayer: CAEAGLLayer {

	// MARK: - Properties

	public let eaglContext = EAGLContext(API: .OpenGLES2)
	private var frameBuffer = GLuint()
	private var renderBuffer = GLuint()

	public override var frame: CGRect {
		didSet {
			glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer)
			eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable: self)
			display()
		}
	}


	// MARK: - Initializers

	public override init!(layer: AnyObject!) {
		super.init(layer: layer)
		initialize()
	}

	public required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}

	deinit {
		EAGLContext.setCurrentContext(eaglContext)
		glDeleteFramebuffersOES(1, &frameBuffer);
		glDeleteRenderbuffersOES(1, &renderBuffer);
		EAGLContext.setCurrentContext(nil)
	}


	// MARK: - Public

	public func render() {
		// Subclasses should override this
	}


	// MARK: - Private

	private func initialize() {
		glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer);
		eaglContext.renderbufferStorage(Int(GL_RENDERBUFFER_OES), fromDrawable: self)

		glGenFramebuffersOES(1, &frameBuffer)
		glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), frameBuffer)

		glGenRenderbuffersOES(1, &renderBuffer)
		glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer)

		glFramebufferRenderbufferOES(GLenum(GL_FRAMEBUFFER_OES), GLenum(GL_COLOR_ATTACHMENT0_OES), GLenum(GL_RENDERBUFFER_OES), renderBuffer);
	}

	public override func display() {
		EAGLContext.setCurrentContext(eaglContext)
		glBindFramebufferOES(GLenum(GL_FRAMEBUFFER_OES), frameBuffer);

		render()

		glBindRenderbufferOES(GLenum(GL_RENDERBUFFER_OES), renderBuffer);
		eaglContext.presentRenderbuffer(Int(GL_RENDERBUFFER_OES))
		EAGLContext.setCurrentContext(nil)
	}
}
