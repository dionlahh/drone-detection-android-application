package org.drone.detection.shared

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform

