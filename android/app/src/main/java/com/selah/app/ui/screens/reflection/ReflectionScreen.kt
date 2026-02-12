package com.selah.app.ui.screens.reflection

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.selah.app.ui.theme.CormorantGaramond
import com.selah.app.ui.theme.SelahColors

/**
 * Reflection screen shown when user chooses "Return to prayer".
 *
 * Displays:
 * - Cross symbol
 * - Scripture text and reference
 * - User's personal commitment (if set)
 * - Tap anywhere to dismiss
 */
@Composable
fun ReflectionScreen(
    scriptureText: String?,
    scriptureRef: String?,
    onDismiss: () -> Unit,
    viewModel: ReflectionViewModel = viewModel()
) {
    val commitment by viewModel.commitment.collectAsState()

    // Use default scripture if not provided
    val displayText = scriptureText ?: "Be still, and know that I am God."
    val displayRef = scriptureRef ?: "Psalm 46:10"

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SelahColors.DeepNavy)
            .clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) {
                onDismiss()
            },
        contentAlignment = Alignment.Center
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Cross symbol
            Text(
                text = "✦",
                fontFamily = CormorantGaramond,
                fontSize = 56.sp,
                color = SelahColors.SacredGold,
                textAlign = TextAlign.Center
            )

            Spacer(Modifier.height(32.dp))

            // Scripture text
            Text(
                text = displayText,
                fontFamily = CormorantGaramond,
                fontSize = 24.sp,
                fontWeight = FontWeight.Normal,
                color = SelahColors.WarmCream,
                textAlign = TextAlign.Center,
                lineHeight = 32.sp
            )

            Spacer(Modifier.height(16.dp))

            // Scripture reference
            Text(
                text = "— $displayRef",
                fontFamily = CormorantGaramond,
                fontSize = 16.sp,
                fontStyle = FontStyle.Italic,
                color = SelahColors.SacredGold.copy(alpha = 0.8f),
                textAlign = TextAlign.Center
            )

            // Personal commitment (if set)
            if (!commitment.isNullOrBlank()) {
                Spacer(Modifier.height(48.dp))

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = SelahColors.SacredGold.copy(alpha = 0.1f)
                    ),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Your Commitment",
                            style = MaterialTheme.typography.labelMedium,
                            color = SelahColors.SacredGold,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = commitment!!,
                            fontFamily = CormorantGaramond,
                            fontSize = 18.sp,
                            color = SelahColors.WarmCream,
                            textAlign = TextAlign.Center,
                            lineHeight = 24.sp
                        )
                    }
                }
            }

            Spacer(Modifier.height(64.dp))

            // Tap to continue hint
            Text(
                text = "Tap anywhere to continue",
                style = MaterialTheme.typography.bodySmall,
                color = SelahColors.SubduedGray,
                textAlign = TextAlign.Center
            )
        }
    }
}
