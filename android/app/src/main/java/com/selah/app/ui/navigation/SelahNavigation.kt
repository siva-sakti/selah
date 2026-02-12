package com.selah.app.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.sp
import androidx.compose.runtime.LaunchedEffect
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.selah.app.ui.screens.apppicker.AppPickerScreen
import com.selah.app.ui.screens.reflection.ReflectionScreen
import com.selah.app.ui.screens.settings.SettingsScreen
import com.selah.app.ui.theme.CormorantGaramond
import com.selah.app.ui.theme.SelahColors
import com.selah.app.ui.theme.SelahSpacing

/**
 * Navigation routes for Selah app
 */
object SelahRoutes {
    const val ONBOARDING = "onboarding"
    const val TODAY = "today"
    const val JOURNEY = "journey"
    const val OFFERINGS = "offerings"
    const val SETTINGS = "settings"
    const val APP_PICKER = "app_picker"
    const val REFLECTION = "reflection"
}

/**
 * Bottom navigation tabs
 */
sealed class BottomNavTab(
    val route: String,
    val label: String,
    val icon: ImageVector
) {
    data object Today : BottomNavTab(SelahRoutes.TODAY, "Today", Icons.Default.Home)
    data object Journey : BottomNavTab(SelahRoutes.JOURNEY, "Journey", Icons.Default.Explore)
    data object Offerings : BottomNavTab(SelahRoutes.OFFERINGS, "Offerings", Icons.Default.FavoriteBorder)
    data object Settings : BottomNavTab(SelahRoutes.SETTINGS, "Settings", Icons.Default.Settings)

    companion object {
        val tabs = listOf(Today, Journey, Offerings, Settings)
    }
}

/**
 * Main navigation host with bottom navigation bar
 *
 * @param showReflection If true, navigate to reflection screen on launch
 * @param scriptureText Scripture text to show on reflection screen
 * @param scriptureRef Scripture reference to show on reflection screen
 */
@Composable
fun SelahNavigation(
    showReflection: Boolean = false,
    scriptureText: String? = null,
    scriptureRef: String? = null
) {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    // Navigate to reflection screen if requested
    LaunchedEffect(showReflection) {
        if (showReflection) {
            navController.navigate(SelahRoutes.REFLECTION) {
                launchSingleTop = true
            }
        }
    }

    // Hide bottom bar on certain screens
    val showBottomBar = currentDestination?.route !in listOf(
        SelahRoutes.APP_PICKER,
        SelahRoutes.ONBOARDING,
        SelahRoutes.REFLECTION
    )

    Scaffold(
        containerColor = SelahColors.DeepNavy,
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(
                    containerColor = SelahColors.DeepNavy,
                    contentColor = SelahColors.SacredGold
                ) {
                    BottomNavTab.tabs.forEach { tab ->
                        val selected = currentDestination?.hierarchy?.any { it.route == tab.route } == true

                        NavigationBarItem(
                            selected = selected,
                            onClick = {
                                navController.navigate(tab.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = {
                                Icon(
                                    imageVector = tab.icon,
                                    contentDescription = tab.label
                                )
                            },
                            label = {
                                Text(text = tab.label)
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = SelahColors.SacredGold,
                                selectedTextColor = SelahColors.SacredGold,
                                unselectedIconColor = SelahColors.SubduedGray,
                                unselectedTextColor = SelahColors.SubduedGray,
                                indicatorColor = SelahColors.SacredGold.copy(alpha = 0.15f)
                            )
                        )
                    }
                }
            }
        }
    ) { paddingValues ->
        NavHost(
            navController = navController,
            startDestination = SelahRoutes.TODAY,
            modifier = Modifier.padding(paddingValues)
        ) {
            composable(SelahRoutes.TODAY) {
                PlaceholderScreen(tabName = "Today")
            }
            composable(SelahRoutes.JOURNEY) {
                PlaceholderScreen(tabName = "Journey")
            }
            composable(SelahRoutes.OFFERINGS) {
                PlaceholderScreen(tabName = "Offerings")
            }
            composable(SelahRoutes.SETTINGS) {
                SettingsScreen(
                    onNavigateToAppPicker = {
                        navController.navigate(SelahRoutes.APP_PICKER)
                    }
                )
            }
            composable(SelahRoutes.APP_PICKER) {
                AppPickerScreen(
                    onNavigateBack = { navController.popBackStack() },
                    onComplete = { navController.popBackStack() }
                )
            }
            composable(SelahRoutes.REFLECTION) {
                ReflectionScreen(
                    scriptureText = scriptureText,
                    scriptureRef = scriptureRef,
                    onDismiss = {
                        navController.popBackStack(SelahRoutes.TODAY, inclusive = false)
                    }
                )
            }
        }
    }
}

/**
 * Placeholder screen for each tab.
 * Shows a gold cross character (✦) above the tab name.
 */
@Composable
fun PlaceholderScreen(tabName: String) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SelahColors.DeepNavy),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "✦",
                fontFamily = CormorantGaramond,
                fontSize = 48.sp,
                color = SelahColors.SacredGold,
                textAlign = TextAlign.Center
            )
            Text(
                text = tabName,
                fontFamily = CormorantGaramond,
                fontSize = 24.sp,
                color = SelahColors.SacredGold,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = SelahSpacing.md)
            )
        }
    }
}

/**
 * Onboarding placeholder screen
 */
@Suppress("UNUSED_PARAMETER")
@Composable
fun OnboardingScreen(onComplete: () -> Unit = {}) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SelahColors.DeepNavy),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "✦",
                fontFamily = CormorantGaramond,
                fontSize = 48.sp,
                color = SelahColors.SacredGold,
                textAlign = TextAlign.Center
            )
            Text(
                text = "Onboarding",
                fontFamily = CormorantGaramond,
                fontSize = 24.sp,
                color = SelahColors.SacredGold,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = SelahSpacing.md)
            )
        }
    }
}
